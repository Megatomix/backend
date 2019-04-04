defmodule Re.Calendars.TourAppointmentsTest do
  use Re.DataCase

  import Commanded.Assertions.EventAssertions

  alias Re.{
    Calendars.TourAppointments,
    Calendars.TourAppointments.Migration,
    Calendars.Events.TourAppointmentScheduled,
    Calendars.Events.TourAppointmentMigrated,
    Calendars.Projections.TourAppointment
  }

  test "a tour appointment should be scheduled" do
    user = insert(:user)
    listing = insert(:listing)
    tour_appointment_command = params_for(:tour_appointment_command)
    TourAppointments.schedule_tour(tour_appointment_command, listing, user)

    assert_receive_event(TourAppointmentScheduled, fn tour_appointment ->
      assert tour_appointment.wants_tour == tour_appointment_command.wants_tour
      assert tour_appointment.wants_pictures == tour_appointment_command.wants_pictures

      assert tour_appointment.options == [
               "2019-03-26T09:00:00",
               "2019-03-26T10:00:00",
               "2019-03-26T11:00:00"
             ]
    end)

    assert [_] = Repo.all(TourAppointment)
  end

  test "a tour appointment should be migrated" do
    now = Timex.now()
    user = insert(:user)
    listing = insert(:listing)

    ta =
      insert(:tour_appointment, listing: listing, user: user, inserted_at: now, updated_at: now)

    Migration.run()

    assert_receive_event(TourAppointmentMigrated, fn tour_appointment ->
      assert tour_appointment.wants_tour == ta.wants_tour
      assert tour_appointment.wants_pictures == ta.wants_pictures
      assert tour_appointment.inserted_at == NaiveDateTime.to_iso8601(ta.inserted_at)
      assert tour_appointment.updated_at == NaiveDateTime.to_iso8601(ta.updated_at)
      assert [_, _, _] = tour_appointment.options
    end)

    assert [_] = Repo.all(TourAppointment)
  end
end
