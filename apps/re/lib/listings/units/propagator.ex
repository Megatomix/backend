defmodule Re.Listings.Units.Propagator do
  @moduledoc """
  Context module for listing units interactions, usually changes in units would
  be replicated/reflected in listings until we migrate replicated structure to units.
  """

  alias Re.Listings

  @unit_cloned_attributes ~w(complement price property_tax maintenance_fee floor rooms bathrooms
    restrooms area garage_spots garage_type suites dependencies balconies)a

  @development_cloned_attributes ~w(description floor_count units_per_floor elevators)a

  def create_listing_from_unit(unit, user) do
    {:ok, development} = Re.Developments.get(unit.development_uuid)
    {:ok, address} = Re.Addresses.get_by_id(development.address_id)

    params =
      static_params()
      |> Map.merge(params_from_development(development))
      |> Map.merge(params_from_unit(unit))

    Listings.insert(params, user: user, address: address, development: development)
  end

  def params_from_unit(unit) do
    Map.take(unit, @unit_cloned_attributes)
  end

  def params_from_development(development) do
    unit_per_floor = Map.get(development, :units_per_floor, 0)

    Map.take(development, @development_cloned_attributes)
    |> Map.put(:unit_per_floor, unit_per_floor)
  end

  def static_params() do
    %{
      has_elevator: true,
      type: "Apartamento",
      is_release: true
      # garage_type: "unknown"
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
