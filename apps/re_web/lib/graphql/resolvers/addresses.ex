defmodule ReWeb.Resolvers.Addresses do
  @moduledoc """
  Resolver module for addresses
  """

  alias Re.{
    Addresses,
    Addresses.Neighborhoods,
    Listings
  }

  def per_listing(listing, params, %{context: %{current_user: current_user}}) do
    admin? = Listings.has_admin_rights?(listing, current_user)

    {:address, Map.put(params, :has_admin_rights, admin?)}
  end

  def per_development(_development, params, %{context: %{current_user: current_user}}) do
    admin? = admin?(current_user)

    {:address, Map.put(params, :has_admin_rights, admin?)}
  end

  def insert(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Addresses, :insert, current_user, %{}),
         {:ok, address} <- Addresses.insert_or_update(params) do
      {:ok, address}
    end
  end

  def neighborhood_description(address, _, _) do
    case Neighborhoods.get_description(address) do
      {:ok, district} -> {:ok, district.description}
      {:error, :not_found} -> {:ok, nil}
    end
  end

  def districts(_, _), do: {:ok, Neighborhoods.districts()}

  def district(params, _), do: Neighborhoods.get_district(params)

  def is_covered(params, _) do
    {:ok, Addresses.is_covered(params)}
  end

  def is_covered(address, _, _), do: {:ok, Addresses.is_covered(address)}

  defp admin?(%{role: "admin"}), do: true
  defp admin?(_), do: false
end
