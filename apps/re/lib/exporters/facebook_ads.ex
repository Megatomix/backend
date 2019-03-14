defmodule Re.Exporters.FacebookAds do
  @moduledoc """
  Listing XML exporter for Facebook Ads.
  """

  @exported_attributes ~w(id url title sell_type description price listing_type
    rooms bathrooms units area_unit area address latitude longitude image)a
  @default_options %{attributes: @exported_attributes}

  @frontend_url Application.get_env(:re_integrations, :frontend_url)
  @image_url "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385"

  def export_listings_xml(listings, options \\ %{}) do
    options = merge_default_options(options)

    listings
    |> Enum.map(&build_node(&1, options))
    |> build_root()
    |> XmlBuilder.document()
    |> XmlBuilder.generate(format: :none)
  end

  def merge_default_options(options) do
    Map.merge(@default_options, options)
  end

  def build_node(listing, options) do
    {"listing", %{}, convert_attributes(listing, options)}
  end

  defp build_root(nodes) do
    {"listings", %{}, nodes}
  end

  def convert_attributes(listing, %{attributes: attributes}) do
    Enum.map(attributes, &convert_attribute_with_cdata(&1, listing))
  end

  defp convert_attribute_with_cdata(:address = attr, listing) do
    convert_attribute(attr, listing)
  end

  defp convert_attribute_with_cdata(:image = attr, listing) do
    convert_attribute(attr, listing)
  end

  defp convert_attribute_with_cdata(attr, listing) do
    {tag, attrs, value} = convert_attribute(attr, listing)
    {tag, attrs, escape_cdata(value)}
  end

  defp convert_attribute(:id, %{id: id}) do
    {"home_listing_id", %{}, id}
  end

  defp convert_attribute(:url, %{id: id}) do
    {"url", %{}, build_url(@frontend_url, "/imoveis/", to_string(id))}
  end

  defp convert_attribute(:title, %{type: type, address: %{city: city}}) do
    {"name", %{}, "#{type} a venda em #{city}"}
  end

  defp convert_attribute(:sell_type, _) do
    {"availability", %{}, "for_sale"}
  end

  defp convert_attribute(:description, %{description: description}) do
    {"description", %{}, description}
  end

  defp convert_attribute(:price, %{price: price}) do
    {"price", %{}, "#{price} BRL"}
  end

  defp convert_attribute(:listing_type, %{type: type}) do
    {"property_type", %{}, expand_type(type)}
  end

  defp convert_attribute(:rooms, %{rooms: rooms}) do
    {"num_beds", %{}, rooms || 0}
  end

  defp convert_attribute(:bathrooms, %{bathrooms: bathrooms}) do
    {"num_baths", %{}, bathrooms || 0}
  end

  defp convert_attribute(:units, _) do
    {"num_units", %{}, 1}
  end

  defp convert_attribute(:address, %{address: address}) do
    {
      "address",
      %{format: "simple"},
      [
        {"component", %{name: "addr1"}, escape_cdata("#{address.street}")},
        {"component", %{name: "city"}, escape_cdata("#{address.city}")},
        {"component", %{name: "region"}, escape_cdata("#{address.neighborhood}")},
        {"component", %{name: "country"}, escape_cdata("Brazil")},
        {"component", %{name: "postal_code"}, escape_cdata("#{address.postal_code}")}
      ]
    }
  end

  defp convert_attribute(:latitude, %{address: %{lat: lat}}) do
    {"latitude", %{}, lat}
  end

  defp convert_attribute(:longitude, %{address: %{lng: lng}}) do
    {"longitude", %{}, lng}
  end

  defp convert_attribute(:image, %{images: []}) do
    {"image", %{}, nil}
  end

  defp convert_attribute(:image, %{images: images}) do
    first_image = Enum.at(images, 0)

    {
      "image",
      %{},
      [
        {"url", %{}, escape_cdata("#{@image_url}/#{first_image.filename}")}
      ]
    }
  end

  defp convert_attribute(:area, %{area: area}) do
    {"area_size", %{}, area}
  end

  defp convert_attribute(:area_unit, _) do
    {"area_unit", %{}, "sq_m"}
  end

  defp expand_type("Apartamento"), do: "apartment"
  defp expand_type("Cobertura"), do: "apartment"
  defp expand_type("Casa"), do: "house"
  defp expand_type(type), do: type

  defp escape_cdata(nil) do
    nil
  end

  defp escape_cdata(value) when is_binary(value) do
    {:cdata, value}
  end

  defp escape_cdata(value) do
    escape_cdata(to_string(value))
  end

  defp build_url(host, path, param) do
    host
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end
end
