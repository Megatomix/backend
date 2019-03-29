defmodule Re.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:timber, "~> 3.1"},
      {:excoveralls, "~> 0.10", only: :test},
      {:junit_formatter, "~> 3.0", only: :test, runtime: false}
    ]
  end

  defp aliases do
    [
      "event_store.reset": ["event_store.drop", "event_store.create", "event_store.init"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      setup: [
        "event_store.create --quiet",
        "event_store.init --quiet",
        "ecto.create --quiet",
        "ecto.migrate --quiet"
      ],
      setup_test: [
        "ecto.create --quiet",
        "ecto.migrate --quiet"
      ],
      reset: ["event_store.drop", "ecto.drop", "setup"],
      test: ["setup_test", "test"],
      "git.hook": &git_hook/1,
      compose: &compose/1
    ]
  end

  defp git_hook(_) do
    Mix.shell().cmd("cp priv/git/pre-commit .git/hooks/pre-commit")
    Mix.shell().cmd("chmod +x .git/hooks/pre-commit")
  end

  @compose_commands ~w(up down ps build)

  defp compose(["server"]) do
    Mix.shell().cmd("docker-compose exec backend mix phx.server")
  end

  defp compose([cmd]) when cmd in @compose_commands do
    Mix.shell().cmd("docker-compose #{cmd}")
  end

  defp compose([cmd]) do
    Mix.shell().info("Command #{cmd} not available.")
  end

  defp compose(_) do
    Mix.shell().info(
      "Use one of compose subcommands: server, #{Enum.join(@compose_commands, ", ")}"
    )
  end
end
