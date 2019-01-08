# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :re,
  ecto_repos: [Re.Repo],
  to: "dev1@email.com|dev2@email.com",
  from: "admin@email.com",
  reply_to: "admin@email.com",
  frontend_url: "http://localhost:3000",
  env: "dev",
  use_logger: true

# Configures the endpoint
config :re, ReWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AFa6xCBxoVrAjCy3YRiSjY9e1TfUn75VT2QhSALdwJ+q/oA693/5mJ0OKptYSIID",
  render_errors: [view: ReWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ReWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :re, ReWeb.Guardian,
  allowed_algos: ["HS256"],
  issuer: "Re",
  ttl: {30, :days},
  allowed_drift: 2000,
  # optional
  verify_issuer: true,
  secret_key: "MDLMflIpKod5YCnkdiY7C4E3ki2rgcAAMwfBl0+vyC5uqJNgoibfQmAh7J3uZWVK",
  serializer: Re.GuardianSerializer

# Configure bcrypt for passwords
config :comeonin, :bcrypt_log_rounds, 4
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

config :re, ReIntegrations.Notifications.Emails.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "SG.x.x"

config :email_checker, validations: [EmailChecker.Check.Format]

config :re, ReIntegrations.Search.Cluster,
  url: "http://localhost:9200",
  api: Elasticsearch.API.HTTP,
  json_library: Poison,
  indexes: %{
    listings: %{
      settings: "priv/elasticsearch/listings.json",
      store: ReIntegrations.Search.Store,
      sources: [Re.Listing],
      bulk_page_size: 5000,
      bulk_wait_interval: 15_000
    }
  }

config :currency_formatter, :whitelist, ["BRL"]

config :account_kit,
  api_version: "v1.0",
  require_appsecret: false

config :mime, :types, %{
  "application/xml" => ["xml"]
}

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"

# Import Timber, structured logging
import_config "timber.exs"
