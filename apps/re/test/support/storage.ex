defmodule Re.Storage do
  @doc """
  Clear the event store and read store databases
  """
  def reset! do
    :ok = Application.stop(:re)

    reset_eventstore()

    {:ok, _} = Application.ensure_all_started(:re)

    reset_readstore()
  end

  defp reset_eventstore do
    :ok = Commanded.EventStore.Adapters.InMemory.reset!()
  end

  def reset_readstore do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Re.Repo)

    Ecto.Adapters.SQL.Sandbox.mode(Re.Repo, {:shared, self()})
  end
end
