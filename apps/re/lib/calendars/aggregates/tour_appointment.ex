defmodule Re.Calendars.Aggregates.TourAppointment do
  defstruct uuid: nil

  alias __MODULE__

  alias Re.Calendars.{
    Commands.ScheduleTourAppointment,
    Commands.MigrateTourAppointment,
    Events.TourAppointmentScheduled,
    Events.TourAppointmentMigrated
  }

  def execute(_, %ScheduleTourAppointment{} = sta) do
    %TourAppointmentScheduled{
      lead_id: sta.lead_id,
      wants_tour: sta.wants_tour,
      wants_pictures: sta.wants_pictures,
      options: sta.options,
      user_id: sta.user_id,
      listing_id: sta.listing_id
    }
  end

  def execute(_, %MigrateTourAppointment{} = mta) do
    %TourAppointmentMigrated{
      lead_id: mta.lead_id,
      wants_tour: mta.wants_tour,
      wants_pictures: mta.wants_pictures,
      options: mta.options,
      user_id: mta.user_id,
      listing_id: mta.listing_id,
      inserted_at: mta.inserted_at,
      updated_at: mta.updated_at
    }
  end

  def apply(%TourAppointment{} = ta, %TourAppointmentScheduled{lead_id: lead_id}) do
    %TourAppointment{ta | uuid: lead_id}
  end

  def apply(%TourAppointment{} = ta, %TourAppointmentMigrated{lead_id: lead_id}) do
    %TourAppointment{ta | uuid: lead_id}
  end
end
