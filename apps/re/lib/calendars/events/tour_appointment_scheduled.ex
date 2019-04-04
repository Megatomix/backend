defmodule Re.Calendars.Events.TourAppointmentScheduled do
  @derive Jason.Encoder
  defstruct [
    :lead_id,
    :wants_tour,
    :wants_pictures,
    :options,
    :user_id,
    :listing_id
  ]
end
