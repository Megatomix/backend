defmodule Re.Application do
  @moduledoc """
  Application module for Re, starts supervision tree.
  """

  use Application

  import Supervisor.Spec

  alias Re.{
    Listings.History.Server,
    Statistics.Visualizations,
    Calendars
  }

  def start(_type, _args) do
    attach_telemetry(Mix.env())

    children =
      [
        supervisor(Re.Repo, []),
        supervisor(Phoenix.PubSub.PG2, [Re.PubSub, []]),
        supervisor(Calendars.Supervisor, [])
      ] ++ extra_processes(Mix.env())

    Supervisor.start_link(children, strategy: :one_for_one, name: Re.Supervisor)
  end

  defp extra_processes(:test), do: []

  defp extra_processes(_),
    do: [
      worker(Server, []),
      worker(Visualizations, [])
    ]

  defp attach_telemetry(:test), do: :ok

  defp attach_telemetry(_) do
    :ok =
      :telemetry.attach(
        "timber-ecto-query-handler",
        [:re, :repo, :query],
        &Timber.Ecto.handle_event/4,
        []
      )
  end
end
