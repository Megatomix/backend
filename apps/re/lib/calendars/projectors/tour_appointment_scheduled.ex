defmodule Re.Calendars.Projectors.TourAppointmentScheduled do
  use Commanded.Projections.Ecto,
    name: "Calendars.Projectors.TourAppointmentScheduled",
    consistency: :strong

  alias Re.Calendars.{
    Events.TourAppointmentScheduled,
    Projections.TourAppointment
  }

  project(%TourAppointmentScheduled{} = tas, _metadata, fn multi ->
    Ecto.Multi.insert(
      multi,
      :tour_appointment_scheduled,
      %TourAppointment{
        uuid: tas.lead_id,
        wants_tour: tas.wants_tour,
        wants_pictures: tas.wants_pictures,
        options: tas.options,
        user_uuid: tas.user_id,
        listing_uuid: tas.listing_id
      }
    )
  end)
end
