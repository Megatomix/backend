defmodule Re.Calendars.TourAppointmentsTest do
  use Re.DataCase

  import Commanded.Assertions.EventAssertions

  alias Re.{
    Calendars.TourAppointments,
    Calendars.Events.TourAppointmentScheduled,
    Calendars.Projections.TourAppointment
  }

  test "a tour appointment should be scheduled" do
    user = insert(:user)
    listing = insert(:listing)
    TourAppointments.schedule_tour(build(:tour_appointment_command), listing, user)

    assert_receive_event(TourAppointmentScheduled, fn tour_appointment ->
      assert tour_appointment.wants_tour
      assert tour_appointment.wants_pictures
      assert tour_appointment.options == []
    end)

    assert [_] = Repo.all(TourAppointment)
  end
end
