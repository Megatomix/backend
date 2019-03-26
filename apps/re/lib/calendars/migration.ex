defmodule Re.Calendars.TourAppointments.Migration do
  require Logger
  require Ecto.Query

  alias Re.{
    Calendars.Commands.MigrateTourAppointment,
    Calendars,
    Repo,
    Router
  }

  def run do
    Calendars.TourAppointment
    |> Ecto.Query.preload([:listing, :user])
    |> Repo.all()
    |> Enum.map(&MigrateTourAppointment.new/1)
    |> Enum.each(&dispatch_command/1)
  end

  def drop, do: Repo.delete_all(Calendars.TourAppointment)

  defp dispatch_command(command) do
    case Router.dispatch(command, consistency: :strong) do
      :ok ->
        Logger.info("Command accepted.")

      failure ->
        Logger.warn(
          "Command rejected. Reason: #{Kernel.inspect(failure)}. Command: #{
            Kernel.inspect(command)
          }"
        )
    end
  end
end
