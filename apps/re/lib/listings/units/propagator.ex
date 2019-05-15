defmodule Re.Listings.Units.Propagator do
  @moduledoc """
  Context module for listing units interactions, usually changes in units would
  be replicated/reflected in listings until we migrate replicated structure to units.
  """

  alias Re.Listings

  @unit_cloned_attributes ~w(complement price property_tax maintenance_fee floor rooms bathrooms
    restrooms area garage_spots garage_type suites dependencies balconies)a

  @development_cloned_attributes ~w(floor_count units_per_floor elevators)a

  def create_listing(unit) do
    params =
      Map.take(unit, @unit_cloned_attributes)
      |> Map.merge(get_development_params(unit))

    %Re.Listing{}
    |> Map.merge(params)
    |> Re.Repo.insert()
  end

  def get_development_params(%{development_uuid: development_uuid}) do
    {:ok, dev} = Re.Developments.get(development_uuid)

    %{
      floor_count: dev.floor_count,
      unit_per_floor: dev.units_per_floor,
      elevators: dev.elevators,
      address_id: dev.address_id
    }
  end

  def update_listing(listing, []), do: {:ok, listing}

  def update_listing(listing, units) do
    params =
      units
      |> Enum.min_by(fn unit -> Map.get(unit, :price) end)
      |> Map.take(@unit_cloned_attributes)

    Listings.update_from_unit_params(listing, params)
  end
end
