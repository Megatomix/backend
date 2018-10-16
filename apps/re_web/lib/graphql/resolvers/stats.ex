defmodule ReWeb.Resolvers.Statistics do
  @moduledoc """
  Resolver module for interests
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def interest_count(listing, _params, %{context: %{loader: loader, current_user: current_user}}) do
    if is_admin(listing, current_user) do
      loader
      |> Dataloader.load(Re.Interests, :interests, listing)
      |> on_load(fn loader ->
        {:ok, Enum.count(Dataloader.get(loader, Re.Interests, :interests, listing))}
      end)
    else
      {:ok, nil}
    end
  end

  def in_person_visit_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    if is_admin(listing, current_user) do
      loader
      |> Dataloader.load(ReStatistics.InPersonVisits, :in_person_visits, listing)
      |> on_load(fn loader ->
        {:ok,
         Enum.count(
           Dataloader.get(loader, ReStatistics.InPersonVisits, :in_person_visits, listing)
         )}
      end)
    else
      {:ok, nil}
    end
  end

  def listings_favorite_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    if is_admin(listing, current_user) do
      loader
      |> Dataloader.load(Re.Favorites, :listings_favorites, listing)
      |> on_load(fn loader ->
        {:ok, Enum.count(Dataloader.get(loader, Re.Favorites, :listings_favorites, listing))}
      end)
    else
      {:ok, nil}
    end
  end

  def tour_visualisation_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    if is_admin(listing, current_user) do
      loader
      |> Dataloader.load(ReStatistics.TourVisualizations, :tour_visualisations, listing)
      |> on_load(fn loader ->
        {:ok,
         Enum.count(
           Dataloader.get(loader, ReStatistics.TourVisualizations, :tour_visualisations, listing)
         )}
      end)
    else
      {:ok, nil}
    end
  end

  def listing_visualisation_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    if is_admin(listing, current_user) do
      loader
      |> Dataloader.load(ReStatistics.ListingVisualizations, :listings_visualisations, listing)
      |> on_load(fn loader ->
        {:ok,
         Enum.count(
           Dataloader.get(
             loader,
             ReStatistics.ListingVisualizations,
             :listings_visualisations,
             listing
           )
         )}
      end)
    else
      {:ok, nil}
    end
  end

  defp is_admin(%{user_id: user_id}, %{id: user_id}), do: true
  defp is_admin(_, %{role: "admin"}), do: true
  defp is_admin(_, _), do: false
end
