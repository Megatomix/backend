defmodule Re.Calendars.Commands.ScheduleTourAppointment do
  defstruct aggregate_id: "tour_appointment",
            lead_id: nil,
            wants_tour: nil,
            wants_pictures: nil,
            options: nil,
            user_id: nil,
            listing_id: nil

  alias Ecto.Changeset

  def new(%{valid?: false} = changeset), do: {:error, changeset}

  def new(changeset) do
    %__MODULE__{
      aggregate_id: "tour_appointment",
      lead_id: Changeset.get_field(changeset, :lead_id),
      wants_tour: Changeset.get_field(changeset, :wants_tour),
      wants_pictures: Changeset.get_field(changeset, :wants_pictures),
      options: Changeset.get_field(changeset, :options),
      user_id: Changeset.get_field(changeset, :user_id),
      listing_id: Changeset.get_field(changeset, :listing_id)
    }
  end
end
