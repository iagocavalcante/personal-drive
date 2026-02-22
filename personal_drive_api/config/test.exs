import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :personal_drive_api, PersonalDriveApi.Repo,
  database: Path.expand("../personal_drive_api_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :personal_drive_api, PersonalDriveApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "yv1eW/gboLUS/5FfYtLt57NgXl1Yj3J1o3UM7aAQCqZS3zJB4v3aLCaX/PR0lep5",
  server: false

# In test we don't send emails.
config :personal_drive_api, PersonalDriveApi.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
