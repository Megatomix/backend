defmodule Mix.Tasks.Re.Pipedrive.Populate do
  @moduledoc """
  Populate listing details and tags from pipedrive data.
  """
  use Mix.Task

  require Logger

  def run(_) do
    Mix.EctoSQL.ensure_started(Re.Repo, [])

    update()

    upsert_tags()

    insert_contacts()
  end

  def update() do
    read_data()
    |> transform_data_for_update()
    |> Enum.map(&operation_update/1)
  end

  def upsert_tags() do
    Enum.map(read_data(), &operation_upsert/1)
  end

  def insert_contacts() do
    {:ok, user} = Re.Accounts.Users.get(1408)

    read_data()
    |> Enum.map(&Map.put(&1, :user, user))
    |> Enum.map(&operation_insert/1)
  end

  def read_data() do
    "priv/deals.json"
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
  end

  defp transform_data_for_update(params) do
    params
    |> Enum.map(fn d -> [:tags, :tags_view] |> Enum.reduce(d, &Map.delete(&2, &1)) end)
    |> Enum.map(fn d ->
      [:orientation, :garage_type, :sun_period] |> Enum.reduce(d, &first_value(&2, &1))
    end)
    |> Enum.map(fn d ->
      [:orientation, :garage_type, :sun_period] |> Enum.reduce(d, &transform/2)
    end)
  end

  def operation_update(attrs) do
    with {id, params} <- Map.pop(attrs, :id),
         {:ok, listing} <- Re.Listings.get(id) do
      listing
      |> Re.Listing.changeset(params, "admin")
      |> Re.Repo.update()
    end
  end

  def operation_upsert(attrs) do
    with {id, params} <- Map.pop(attrs, :id),
         {:ok, listing} <- Re.Listings.get(id),
         {:ok, tags_uuid} <- fetch_tags(Map.get(params, :tags)) do
      Re.Listings.upsert_tags(listing, tags_uuid)
    else
      _ -> {:ok, Map.get(attrs, :id)}
    end
  end

  def operation_insert(attrs) do
    with {id, params} <- Map.pop(attrs, :id),
         {user, params} <- Map.pop(params, :user),
         {owner_contact_params, _} <- Map.pop(params, :owner_contact),
         {:ok, owner_contact} <- upsert_owner_contact(owner_contact_params),
         {:ok, listing} <- Re.Listings.get_partial_preloaded(id, [:address, :user]) do
      Re.Listings.update(listing, %{},
        address: listing.address,
        user: user,
        owner_contact: owner_contact
      )
    else
      _ -> {:ok, Map.get(attrs, :id)}
    end
  end

  defp first_value(params, key) do
    Map.replace!(params, key, get_value(Map.get(params, key)))
  end

  defp get_value(value) when is_list(value) and length(value) > 0, do: Enum.at(value, 0)
  defp get_value(value) when is_list(value), do: nil
  defp get_value(value), do: value

  defp transform(:garage_type = key, params) do
    Map.put(
      params,
      key,
      transform_value(key, Map.get(params, key))
    )
  end

  defp transform(:orientation = key, params) do
    Map.put(
      params,
      key,
      transform_value(key, Map.get(params, key))
    )
  end

  defp transform(:sun_period = key, params) do
    Map.put(
      params,
      key,
      transform_value(key, Map.get(params, key))
    )
  end

  defp transform(_, params), do: params

  defp transform_value(:garage_type, "condominio"), do: "condominium"
  defp transform_value(:garage_type, "escritura"), do: "contract"

  defp transform_value(:orientation, "frente"), do: "frontside"
  defp transform_value(:orientation, "fundos"), do: "backside"
  defp transform_value(:orientation, "lateral"), do: "lateral"
  defp transform_value(:orientation, "meio"), do: "inside"

  defp transform_value(:sun_period, "manha"), do: "morning"
  defp transform_value(:sun_period, "tarde"), do: "evening"

  defp transform_value(_, _), do: nil

  defp fetch_tags(nil), do: {:error, :no_tags}
  defp fetch_tags([]), do: {:error, :empty_tags}

  defp fetch_tags(names_slug) do
    {:ok, Enum.map(Re.Tags.list_by_slugs(names_slug), & &1.uuid)}
  end

  defp upsert_owner_contact(nil), do: {:error, :nodata}
  defp upsert_owner_contact(params), do: Re.OwnerContacts.upsert(params)
end
