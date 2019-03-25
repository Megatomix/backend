defmodule Re.Calendars.Projections.TourAppointment do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "tour_appointments_projection" do
    field :wants_pictures, :boolean
    field :wants_tour, :boolean

    embeds_many :options, Re.Calendars.Option

    belongs_to :user, Re.User,
      references: :uuid,
      foreign_key: :user_uuid,
      type: Ecto.UUID

    belongs_to :listing, Re.Listing,
      references: :uuid,
      foreign_key: :listing_uuid,
      type: Ecto.UUID

    timestamps()
  end
end
