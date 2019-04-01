defmodule Re.Calendars.Handlers.NotifyEmail do
  use Commanded.Event.Handler,
    name: "Calendars.Handlers.NotifyEmail",
    subscribe_to: "tour_appointment",
    consistency: :eventual

  require Logger
  require Ecto.Query

  alias Re.{
    Calendars.Events,
    Calendars.Projectors,
    Calendars.Projections.TourAppointment,
    HandlerHelper,
    Repo
  }

  alias ReIntegrations.Notifications.Emails.{
    Server,
    User
  }

  def handle(%Events.TourAppointmentScheduled{lead_id: uuid}, metadata) do
    case HandlerHelper.wait_for(metadata, Projectors.TourAppointmentScheduled) do
      :ok ->
        notify(uuid, metadata)

      response ->
        Logger.warn(
          "There's was an issue waiting for Projectors.TourAppointmentScheduled. Response: #{
            Kernel.inspect(response)
          }"
        )
    end
  end

  defp notify(uuid, metadata) do
    TourAppointment
    |> Ecto.Query.preload([:listing, :user])
    |> Repo.get(uuid)
    |> case do
      nil ->
        Logger.warn(
          "TourAppointment with uuid: #{uuid} was not found. Metadata: #{Kernel.inspect(metadata)}"
        )

      tour_appointment ->
        GenServer.cast(Server, {User, :tour_appointment, [tour_appointment]})
    end
  end
end
