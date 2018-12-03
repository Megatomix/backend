defmodule Re.Listings.Related do
  @moduledoc """
  Module that contains related listings queries based on a listing
  It takes apart a few common attributes and attempts queries
  """
  import Ecto.Query

  alias Re.{
    Images,
    Listing,
    Listings,
    Listings.Queries,
    Repo
  }

  @relations [
    :address,
    images: Images.Queries.listing_preload()
  ]

  def get(listing, params \\ %{}) do
    listing = Repo.preload(listing, :address)

    query =
      ~w(price address rooms)a
      |> Enum.reduce(Listing, &build_query(&1, listing, &2))
      |> exclude_current(listing)
      |> Queries.excluding(params)
      |> Queries.exclude_blacklisted(params)
      |> Queries.active()
      |> Queries.by_city(listing)
      |> Queries.order_by()
      |> Queries.limit(params)
      |> Queries.preload_relations(@relations)

    %{
      listings: Repo.all(query),
      remaining_count: Listings.remaining_count(query, params)
    }
  end

  defp exclude_current(query, listing), do: from(l in query, where: ^listing.id != l.id)

  defp build_query(:address, listing, query) do
    from(
      l in query,
      join: a in assoc(l, :address),
      or_where: ^listing.address.neighborhood == a.neighborhood
    )
  end

  defp build_query(:price, %{price: price}, query) when not is_nil(price) do
    price_diff = price * 0.25
    floor = trunc(price - price_diff)
    ceiling = trunc(price + price_diff)

    from(l in query, or_where: l.price >= ^floor and l.price <= ^ceiling)
  end

  defp build_query(:rooms, %{rooms: rooms}, query) when not is_nil(rooms) do
    rooms_ceiling = rooms + 1
    rooms_floor = rooms - 1

    from(l in query, or_where: l.rooms >= ^rooms_floor and l.rooms <= ^rooms_ceiling)
  end

  defp build_query(_, _, query), do: query
end
