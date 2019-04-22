defmodule Re.Filtering.Listings do
  @moduledoc """
  Module for grouping listing filter queries
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "listings_filter" do
    field :types, {:array, :string}
    field :min_price, :integer
    field :max_price, :integer
    field :min_rooms, :integer
    field :max_rooms, :integer
    field :min_area, :integer
    field :max_area, :integer
    field :max_garage_spots, :integer
    field :min_garage_spots, :integer
    field :neighborhoods_slugs, {:array, :string}
  end

  @filters ~w(max_price min_price max_rooms min_rooms min_area max_area
              types neighborhoods_slugs max_garage_spots min_garage_spots)a

  def changeset(struct, params \\ %{}), do: cast(struct, params, @filters)

  def apply(query, params) do
    params
    |> cast()
    |> build_query(query)
  end

  def cast(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Map.get(:changes)
  end

  defp build_query(params, _query) do
    result = Enum.reduce(params, [], fn el, acc -> [attr_filter(el) | acc] end)

    %{
      query: %{
        bool: %{
          filter: result
        }
      }
    }
  end

  defp attr_filter({:min_price, min_price}) do
    %{
      range: %{
        price: %{
          gte: min_price
        }
      }
    }
  end

  defp attr_filter({:max_price, max_price}) do
    %{
      range: %{
        price: %{
          lte: max_price
        }
      }
    }
  end

  defp attr_filter({:min_rooms, min_rooms}) do
    %{
      range: %{
        rooms: %{
          gte: min_rooms
        }
      }
    }
  end

  defp attr_filter({:max_rooms, max_rooms}) do
    %{
      range: %{
        rooms: %{
          lte: max_rooms
        }
      }
    }
  end

  defp attr_filter({:min_area, min_area}) do
    %{
      range: %{
        area: %{
          gte: min_area
        }
      }
    }
  end

  defp attr_filter({:max_area, max_area}) do
    %{
      range: %{
        area: %{
          lte: max_area
        }
      }
    }
  end

  defp attr_filter({:min_garage_spots, min_garage_spots}) do
    %{
      range: %{
        garage_spots: %{
          gte: min_garage_spots
        }
      }
    }
  end

  defp attr_filter({:max_garage_spots, max_garage_spots}) do
    %{
      range: %{
        garage_spots: %{
          lte: max_garage_spots
        }
      }
    }
  end

  defp attr_filter({:types, types}) do
    %{
      terms: %{
        type: types
      }
    }
  end

  defp attr_filter({:neighborhoods_slugs, neighborhood_slugs}) do
    %{
      terms: %{
        neighborhood_slug: neighborhood_slugs
      }
    }
  end
end
