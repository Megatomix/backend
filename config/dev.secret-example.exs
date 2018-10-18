use Mix.Config

# To generate api_key for Sendgrid, open a free SendGrid account
# at sendgrid.com and generate a personal api key.
# https://app.sendgrid.com/settings/api_keys
#
# To generate keys for Guardian, open an iex session in the terminal with:
# iex -S mix phx.server
# then run
# JOSE.JWS.generate_key(%{"alg" => "ES512"}) |> JOSE.JWK.to_map |> elem(1)
#  and copy the hashes for "d", "x", and "y".

config :re, ReWeb.Guardian,
  allowed_algos: ["ES512"],
  secret_key: %{
    "alg" => "ES512",
    "crv" => "P-521",
    "d" => "xxxxxx",
    "kty" => "EC",
    "use" => "sig",
    "x" => "xxxxxx",
    "y" => "xxxxxx"
  }

# The emails below are used when a visitor
# fills out a form expressing interest in a listing.
# Both `to:` and `from:` can be individual emails
# or multiple emails, in which case use `|` as separator.
config :re,
  to: "dev1@email.com|dev2@email.com",
  from: "admin@email.com",
  pipedrive_url: "https://yourcompany.pipedrive.com/v1/",
  pipedrive_token: "your_token",
  pipedrive_webhook_user: "pipedrive_user",
  pipedrive_webhook_pass: "pipedrive_pass"

# The configuration below is for logging in with account kit
# Retrieve your  id and secret from https://developers.facebook.com/apps
config :account_kit,
  app_id: "your_dev_app_id",
  app_secret: "your_dev_app_secret",
  require_appsecret: false,
  api_version: "v1.0"

config :honeybadger,
  api_key: "HONEYBADGER_API_KEY"
