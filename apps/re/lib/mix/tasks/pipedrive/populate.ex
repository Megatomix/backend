defmodule Mix.Tasks.Re.Pipedrive.Populate do
  use Mix.Task

  require Logger

  def run(_) do
    Mix.EctoSQL.ensure_started(Re.Repo, [])
  end

  def update() do
    data()
    |> data_update()
    |> Enum.map(&operation_update/1)
  end

  def upsert_tags() do
    Enum.map(data(), &operation_upsert/1)
  end

  def data() do
    "priv/deals.json"
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
  end

  def data_update(datum) do
    datum
    |> Enum.map(fn d -> [:tags, :tags_view] |> Enum.reduce(d, &Map.delete(&2, &1)) end)
    |> Enum.map(fn d ->
      [:orientation, :garage_type, :sun_period] |> Enum.reduce(d, &first_value(&2, &1))
    end)
    |> Enum.map(fn d ->
      [:orientation, :garage_type, :sun_period] |> Enum.reduce(d, &transform/2)
    end)
  end

  def operation_update(datum) do
    with {id, params} <- Map.pop(datum, :id),
         {:ok, listing} <- Re.Listings.get(id) do
      Re.Listing.changeset(listing, params, "admin")
      |> Re.Repo.update()
    end
  end

  def operation_upsert(datum) do
    with {id, params} <- Map.pop(datum, :id),
         {:ok, listing} <- Re.Listings.get(id),
         {:ok, tags_uuid} <- fetch_tags(Map.get(params, :tags)) do
      Re.Listings.upsert_tags(listing, tags_uuid)
    else
      _ -> {:ok, Map.get(datum, :id)}
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

  def fetch_tags(nil), do: {:error, :no_tags}
  def fetch_tags([]), do: {:error, :empty_tags}

  def fetch_tags(names_slug) do
    {:ok, Enum.map(Re.Tags.list_by_slugs(names_slug), & &1.uuid)}
  end
end
