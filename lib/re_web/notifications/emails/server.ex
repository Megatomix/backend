defmodule ReWeb.Notifications.Emails.Server do
  @moduledoc """
  Module responsible for sending email
  """
  use GenServer
  use Retry

  require Logger

  alias Re.{
    Accounts.Users,
    Listings,
    PriceSuggestions.Request,
    Repo
  }

  alias ReWeb.{
    Schema,
    Notifications.Emails.Mailer,
    Notifications.UserEmail
  }

  alias ReWeb.Endpoint, as: PubSub

  @env Application.get_env(:re, :env)

  @spec start_link :: GenServer.start_link()
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term) :: {:ok, term}
  def init(args) do
    if Mix.env() != :test do
      subscribe("subscription { listingInserted { id owner { id } } }")
      subscribe("subscription { contactRequested { id } }")
      subscribe("subscription { priceSuggestionRequested { id suggestedPrice} }")
      subscribe("subscription { userRegistered { user { id } } }")
      subscribe("subscription { notificationCoverageAsked { id } }")
      subscribe("subscription { tourScheduled { id } }")
    end

    {:ok, args}
  end

  def handle_call(:inspect, _caller, state), do: {:reply, state, state}

  defp subscribe(subscription) do
    case Absinthe.run(subscription, Schema, context: %{pubsub: PubSub, current_user: :system}) do
      {:ok, %{"subscribed" => topic}} ->
        PubSub.subscribe(topic)

      error ->
        Logger.warn("Subscription error: #{inspect(error)}")

        :nothing
    end
  end

  @spec handle_cast({atom(), atom(), [any]}, any) :: {:noreply, any}

  def handle_cast({module, :price_updated, new_price, listing}, state) do
    replies =
      listing
      |> Repo.preload(:favorited)
      |> Map.get(:favorited)
      |> Enum.filter(&notify?/1)
      |> Enum.map(&handle_cast({module, :price_updated, [&1, new_price, listing]}, state))

    {:noreply, Enum.reduce(replies, state, fn {:noreply, st}, state -> [st | state] end)}
  end

  def handle_cast({module, :listing_added, user, listing}, state) do
    if notify?(user) do
      handle_cast({module, :listing_added, [user, listing]}, state)
    else
      {:noreply, state}
    end
  end

  def handle_cast({module, function, args}, state) do
    case :erlang.apply(module, function, args) do
      %Swoosh.Email{} = email ->
        deliver(email, state)

      error ->
        Logger.error("Email creation failed. Reason: #{inspect(error)}")
        {:noreply, [{:error, error, {module, function, args}} | state]}
    end
  end

  defp notify?(%{notification_preferences: %{email: false}}), do: false
  defp notify?(_), do: @env not in ~w(staging test)

  defp deliver(email, state) do
    retry with: exp_backoff() |> randomize() |> expiry(30_000), rescue_only: [TimeoutError] do
      Mailer.deliver(email)
    after
      {:ok, _} -> {:noreply, state}
    else
      error ->
        Logger.error("Email delivery failed. Reason: #{inspect(error)}")
        {:noreply, [{:error, error, email} | state]}
    end
  end

  @spec handle_info(Phoenix.Socket.Broadcast.t(), any) :: {:noreply, any}
  def handle_info(%Phoenix.Socket.Broadcast{payload: %{result: %{data: data}}}, state) do
    handle_data(data, state)
  end

  def handle_info(_, state), do: {:noreply, state}

  defp handle_data(
         %{
           "priceSuggestionRequested" => %{
             "id" => request_id,
             "suggestedPrice" => suggested_price
           }
         },
         state
       ) do
    case Repo.get(Request, request_id) do
      nil ->
        {:noreply, state}

      request ->
        request = Repo.preload(request, [:address, :user])

        handle_cast({UserEmail, :price_suggestion_requested, [request, suggested_price]}, state)
    end
  end

  defp handle_data(
         %{"listingInserted" => %{"id" => listing_id, "owner" => %{"id" => user_id}}},
         state
       ) do
    case {Users.get(user_id), Listings.get(listing_id)} do
      {{:ok, user}, {:ok, listing}} ->
        handle_cast({UserEmail, :listing_added_admin, [user, listing]}, state)

      _ ->
        {:noreply, state}
    end
  end

  import Ecto.Query, only: [preload: 2]

  defp handle_data(%{"contactRequested" => %{"id" => id}}, state) do
    Re.Interests.ContactRequest
    |> preload(:user)
    |> Repo.get(id)
    |> case do
      nil ->
        {:noreply, [{:error, "Request Contact id #{id} does not exist"} | state]}

      %{user: nil} = contact_request ->
        handle_cast({UserEmail, :contact_request, [contact_request]}, state)

      %{user: user} = contact_request ->
        handle_cast({UserEmail, :contact_request, [merge_params(user, contact_request)]}, state)

      error ->
        {:noreply, [{:error, error} | state]}
    end
  end

  defp handle_data(%{"notificationCoverageAsked" => %{"id" => id}}, state) do
    Re.Interests.NotifyWhenCovered
    |> preload([:user, :address])
    |> Repo.get(id)
    |> case do
      nil ->
        {:noreply, [{:error, "Notify when Covered id #{id} does not exist"} | state]}

      notify_when_covered ->
        handle_cast({UserEmail, :notification_coverage_asked, [notify_when_covered]}, state)
    end
  end

  defp handle_data(%{"tourScheduled" => %{"id" => id}}, state) do
    Re.Calendars.TourAppointment
    |> preload([:user, :listing])
    |> Repo.get(id)
    |> case do
      nil ->
        {:noreply, [{:error, "Tour Apponintment with id #{id} does not exist"} | state]}

      %{user: %{role: "user"}} = tour_appointment ->
        handle_cast({UserEmail, :tour_appointment, [tour_appointment]}, state)

      _ ->
        {:noreply, state}
    end
  end

  defp merge_params(user, contact_request) do
    user = Map.take(user, ~w(name email phone)a)
    contact_request = Map.take(contact_request, ~w(name email phone message)a)
    Map.merge(user, contact_request, &map_merger/3)
  end

  defp map_merger(_key, nil, v2), do: v2
  defp map_merger(_key, v1, nil), do: v1
  defp map_merger(_key, _v1, v2), do: v2
end
