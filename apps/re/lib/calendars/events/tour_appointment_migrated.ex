defmodule Re.Calendars.Events.TourAppointmentMigrated do
  @derive Jason.Encoder
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
end
