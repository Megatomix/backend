defmodule Re.Router do
  use Commanded.Commands.Router

  alias Re.Calendars.{
    Aggregates.TourAppointment,
    Commands.ScheduleTourAppointment,
    Commands.MigrateTourAppointment
  }

  dispatch(
    [
      ScheduleTourAppointment,
      MigrateTourAppointment
    ],
    to: TourAppointment,
    identity: :lead_id
  )
end
