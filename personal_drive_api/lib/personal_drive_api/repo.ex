defmodule PersonalDriveApi.Repo do
  use Ecto.Repo,
    otp_app: :personal_drive_api,
    adapter: Ecto.Adapters.SQLite3
end
