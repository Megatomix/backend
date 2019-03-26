defmodule Re.Calendars.Commands.MigrateTourAppointment do
  defstruct [
    :lead_id,
    :wants_tour,
    :wants_pictures,
    :options,
    :user_id,
    :listing_id,
    :inserted_at,
    :updated_at
  ]

  def new(tour_appointment) do
    %__MODULE__{
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
