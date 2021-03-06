defmodule Re.Addresses.District do
  @moduledoc """
  Model for districts.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.Slugs

  schema "districts" do
    field :state, :string
    field :city, :string
    field :name, :string
    field :state_slug, :string
    field :city_slug, :string
    field :name_slug, :string
    field :description, :string
    field :status, :string, default: "inactive"

    timestamps()
  end

  @required ~w(state city name description)a
  @optional ~w(status)a
  @params @required ++ @optional

  @sluggified_attr ~w(state city name)a

  @statuses ~w(active inactive)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> validate_length(:name, max: 128)
    |> validate_length(:city, max: 128)
    |> validate_length(:state, is: 2)
    |> unique_constraint(:neighborhood, name: :neighborhood)
    |> validate_inclusion(:status, @statuses,
      message: "should be one of: [#{Enum.join(@statuses, " ")}]"
    )
    |> generate_slugs()
  end

  def generate_slugs(%{valid?: false} = changeset), do: changeset

  def generate_slugs(changeset) do
    Enum.reduce(@sluggified_attr, changeset, &Slugs.generate_slug(&1, &2))
  end
end
