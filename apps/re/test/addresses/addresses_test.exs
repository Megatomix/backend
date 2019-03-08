defmodule Re.AddressesTest do
  use Re.ModelCase

  alias Re.{
    Address,
    Addresses,
    Repo
  }

  import Re.Factory

  describe "get/1" do
    test "find address" do
      address = insert(:address)

      {:ok, created_address} =
        Addresses.get(%{
          "street" => address.street,
          "street_number" => address.street_number,
          "postal_code" => address.postal_code
        })

      assert created_address.id == address.id
      assert created_address.street == address.street
      assert created_address.street_slug == address.street_slug
      assert created_address.street_number == address.street_number
      assert created_address.neighborhood == address.neighborhood
      assert created_address.neighborhood_slug == address.neighborhood_slug
      assert created_address.city == address.city
      assert created_address.city_slug == address.city_slug
      assert created_address.state == address.state
      assert created_address.state_slug == address.state_slug
      assert created_address.postal_code == address.postal_code
      assert created_address.lat == address.lat
      assert created_address.lng == address.lng
    end

    test "find address atom keys" do
      address = insert(:address)

      {:ok, created_address} =
        Addresses.get(%{
          street: address.street,
          street_number: address.street_number,
          postal_code: address.postal_code
        })

      assert created_address.id == address.id
      assert created_address.street == address.street
      assert created_address.street_slug == address.street_slug
      assert created_address.street_number == address.street_number
      assert created_address.neighborhood == address.neighborhood
      assert created_address.neighborhood_slug == address.neighborhood_slug
      assert created_address.city == address.city
      assert created_address.city_slug == address.city_slug
      assert created_address.state == address.state
      assert created_address.state_slug == address.state_slug
      assert created_address.postal_code == address.postal_code
      assert created_address.lat == address.lat
      assert created_address.lng == address.lng
    end
  end

  describe "insert_or_update/1" do
    test "create new address" do
      {:ok, created_address} =
        Addresses.insert_or_update(%{
          "street" => "test st",
          "street_number" => "101",
          "neighborhood" => "Dówntówn",
          "city" => "Neverland Town",
          "state" => "ST",
          "postal_code" => "11111-111",
          "lat" => "-1",
          "lng" => "1"
        })

      assert created_address.id
      assert created_address.street == "test st"
      assert created_address.street_slug == "test-st"
      assert created_address.street_number == "101"
      assert created_address.neighborhood == "Dówntówn"
      assert created_address.neighborhood_slug == "downtown"
      assert created_address.city == "Neverland Town"
      assert created_address.city_slug == "neverland-town"
      assert created_address.state == "ST"
      assert created_address.state_slug == "st"
      assert created_address.postal_code == "11111-111"
      assert created_address.lat == -1.0
      assert created_address.lng == 1.0
    end

    test "should insert new address with different unique parameters" do
      address = insert(:address)

      address_params =
        address
        |> Map.from_struct()
        |> Map.put(:street, "new street name")
        |> Map.put(:street_number, "55")
        |> Map.put(:postal_code, "54321-876")
        |> Map.delete(:__meta__)
        |> stringify_keys()

      {:ok, created_address} = Addresses.insert_or_update(address_params)

      assert address.id != created_address.id
      assert created_address.street == "new street name"
      assert created_address.street_slug == "new-street-name"
      assert created_address.street_number == "55"
      assert created_address.postal_code == "54321-876"

      assert address == Repo.get(Address, address.id)
    end

    test "should do nothing when there's no change" do
      address = insert(:address)

      address_params =
        address
        |> Map.from_struct()
        |> Map.delete(:__meta__)
        |> stringify_keys()

      assert {:ok, new_address} = Addresses.insert_or_update(address_params)
      assert address == new_address
      assert address == Repo.get(Address, address.id)
    end

    test "update address when exists but the not-unique parameters are different" do
      address = insert(:address)

      {:ok, updated_address} =
        Addresses.insert_or_update(%{
          "street" => address.street,
          "street_number" => address.street_number,
          "neighborhood" => address.neighborhood,
          "city" => address.city,
          "state" => address.state,
          "postal_code" => address.postal_code,
          "lat" => "-20.123",
          "lng" => "-40.123"
        })

      assert updated_address.id == address.id
      assert updated_address.street == address.street
      assert updated_address.street_slug == address.street_slug
      assert updated_address.street_number == address.street_number
      assert updated_address.neighborhood == address.neighborhood
      assert updated_address.neighborhood_slug == address.neighborhood_slug
      assert updated_address.city == address.city
      assert updated_address.city_slug == address.city_slug
      assert updated_address.state == address.state
      assert updated_address.state_slug == address.state_slug
      assert updated_address.postal_code == address.postal_code
      assert updated_address.lat == -20.123
      assert updated_address.lng == -40.123
    end

    test "create new address atom keys" do
      {:ok, created_address} =
        Addresses.insert_or_update(%{
          street: "test st",
          street_number: "101",
          neighborhood: "Dówntówn",
          city: "Neverland Town",
          state: "ST",
          postal_code: "11111-111",
          lat: "-1",
          lng: "1"
        })

      assert created_address.id
      assert created_address.street == "test st"
      assert created_address.street_slug == "test-st"
      assert created_address.street_number == "101"
      assert created_address.neighborhood == "Dówntówn"
      assert created_address.neighborhood_slug == "downtown"
      assert created_address.city == "Neverland Town"
      assert created_address.city_slug == "neverland-town"
      assert created_address.state == "ST"
      assert created_address.state_slug == "st"
      assert created_address.postal_code == "11111-111"
      assert created_address.lat == -1.0
      assert created_address.lng == 1.0
    end

    test "should insert new address with different unique parameters atom keys" do
      address = insert(:address)

      address_params =
        address
        |> Map.from_struct()
        |> Map.put(:street, "new street name")
        |> Map.put(:street_number, "55")
        |> Map.put(:postal_code, "54321-876")
        |> Map.delete(:__meta__)

      {:ok, created_address} = Addresses.insert_or_update(address_params)

      assert address.id != created_address.id
      assert created_address.street == "new street name"
      assert created_address.street_slug == "new-street-name"
      assert created_address.street_number == "55"
      assert created_address.postal_code == "54321-876"

      assert address == Repo.get(Address, address.id)
    end

    test "should do nothing when there's no change atom keys" do
      address = insert(:address)

      address_params =
        address
        |> Map.from_struct()
        |> Map.delete(:__meta__)

      assert {:ok, new_address} = Addresses.insert_or_update(address_params)
      assert address == new_address
      assert address == Repo.get(Address, address.id)
    end

    test "update address when exists but the not-unique parameters are different atom keys" do
      address = insert(:address)

      {:ok, updated_address} =
        Addresses.insert_or_update(%{
          street: address.street,
          street_number: address.street_number,
          neighborhood: address.neighborhood,
          city: address.city,
          state: address.state,
          postal_code: address.postal_code,
          lat: "-20.123",
          lng: "-40.123"
        })

      assert updated_address.id == address.id
      assert updated_address.street == address.street
      assert updated_address.street_slug == address.street_slug
      assert updated_address.street_number == address.street_number
      assert updated_address.neighborhood == address.neighborhood
      assert updated_address.neighborhood_slug == address.neighborhood_slug
      assert updated_address.city == address.city
      assert updated_address.city_slug == address.city_slug
      assert updated_address.state == address.state
      assert updated_address.state_slug == address.state_slug
      assert updated_address.postal_code == address.postal_code
      assert updated_address.lat == -20.123
      assert updated_address.lng == -40.123
    end

    test "should create address filling postal code with zeroes when address does not exists" do
      {:ok, created_address} =
        Addresses.insert_or_update(%{
          "street" => "test st",
          "street_number" => "101",
          "neighborhood" => "Dówntówn",
          "city" => "Neverland Town",
          "state" => "ST",
          "postal_code" => "11111",
          "lat" => "-1",
          "lng" => "1"
        })

      assert created_address.id
      assert created_address.street == "test st"
      assert created_address.street_slug == "test-st"
      assert created_address.street_number == "101"
      assert created_address.neighborhood == "Dówntówn"
      assert created_address.neighborhood_slug == "downtown"
      assert created_address.city == "Neverland Town"
      assert created_address.city_slug == "neverland-town"
      assert created_address.state == "ST"
      assert created_address.state_slug == "st"
      assert created_address.postal_code == "11111-000"
      assert created_address.lat == -1.0
      assert created_address.lng == 1.0
    end

    test "should use already created address when address does exists with postal code filled with zero" do
      address = insert(:address, postal_code: "99999-000")

      {:ok, updated_address} =
        Addresses.insert_or_update(%{
          "street" => address.street,
          "street_number" => address.street_number,
          "neighborhood" => address.neighborhood,
          "city" => address.city,
          "state" => address.state,
          "postal_code" => "99999",
          "lat" => address.lat,
          "lng" => address.lng
        })

      assert updated_address.id == address.id
      assert updated_address.street == address.street
      assert updated_address.street_slug == address.street_slug
      assert updated_address.street_number == address.street_number
      assert updated_address.neighborhood == address.neighborhood
      assert updated_address.neighborhood_slug == address.neighborhood_slug
      assert updated_address.city == address.city
      assert updated_address.city_slug == address.city_slug
      assert updated_address.state == address.state
      assert updated_address.state_slug == address.state_slug
      assert updated_address.postal_code == address.postal_code
      assert updated_address.lat == address.lat
      assert updated_address.lng == address.lng
    end

    test "should use already created address when address does exists with postal code filled with zero and has atoms as keys" do
      address = insert(:address, postal_code: "99999-000")

      {:ok, updated_address} =
        Addresses.insert_or_update(%{
          street: address.street,
          street_number: address.street_number,
          neighborhood: address.neighborhood,
          city: address.city,
          state: address.state,
          postal_code: "99999",
          lat: address.lat,
          lng: address.lng
        })

      assert updated_address.id == address.id
      assert updated_address.street == address.street
      assert updated_address.street_slug == address.street_slug
      assert updated_address.street_number == address.street_number
      assert updated_address.neighborhood == address.neighborhood
      assert updated_address.neighborhood_slug == address.neighborhood_slug
      assert updated_address.city == address.city
      assert updated_address.city_slug == address.city_slug
      assert updated_address.state == address.state
      assert updated_address.state_slug == address.state_slug
      assert updated_address.postal_code == address.postal_code
      assert updated_address.lat == address.lat
      assert updated_address.lng == address.lng
    end
  end

  defp stringify_keys(%{} = map) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
