defmodule Re.Accounts do
  @moduledoc """
  Context boundary to Accounts management
  """

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query
end
