defmodule Re.Calendars.Projectors.TourAppointmentScheduled do
  use Commanded.Projections.Ecto,
    name: "Calendars.Projectors.TourAppointmentScheduled",
    consistency: :strong

  alias Re.Calendars.{
    Events.TourAppointmentScheduled,
    Events.TourAppointmentMigrated,
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
        options: Enum.map(tas.options, &cast_options/1),
        user_uuid: tas.user_id,
        listing_uuid: tas.listing_id
      }
    )
  end)

  defp cast_options(option), do: %Re.Calendars.Option{datetime: option}

  project(%TourAppointmentMigrated{} = tam, _metadata, fn multi ->
    Ecto.Multi.insert(
      multi,
      :tour_appointment_migrated,
      %TourAppointment{
        uuid: tam.lead_id,
        wants_tour: tam.wants_tour,
        wants_pictures: tam.wants_pictures,
        options: tam.options,
        user_uuid: tam.user_id,
        listing_uuid: tam.listing_id,
        inserted_at: NaiveDateTime.from_iso8601!(tam.inserted_at),
        updated_at: NaiveDateTime.from_iso8601!(tam.updated_at)
      }
    )
  end)
end
