defmodule Re.Calendars.Commands.MigrateTourAppointment do
  defstruct aggregate_id: "tour_appointment",
            lead_id: nil,
            wants_tour: nil,
            wants_pictures: nil,
            options: nil,
            user_id: nil,
            listing_id: nil,
            inserted_at: nil,
            updated_at: nil

  def new(tour_appointment) do
    %__MODULE__{
      aggregate_id: "tour_appointment",
      lead_id: UUID.uuid4(),
      wants_tour: tour_appointment.wants_tour,
      wants_pictures: tour_appointment.wants_pictures,
      options: tour_appointment.options,
      user_id: tour_appointment.user.uuid,
      listing_id: tour_appointment.listing.uuid,
      inserted_at: tour_appointment.inserted_at,
      updated_at: tour_appointment.updated_at
    }
  end
end
