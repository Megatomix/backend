defmodule Re.Calendars.Supervisor do
  use Supervisor

  alias Re.Calendars.Projectors.TourAppointmentScheduled

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        TourAppointmentScheduled
      ],
      strategy: :one_for_one
    )
  end
end
