defmodule PersonalDriveApiWeb.UsageController do
  use PersonalDriveApiWeb, :controller

  alias PersonalDriveApi.Storage

  defp current_user(conn) do
    conn.assigns[:current_user]
  end

  # Get storage usage for current user
  def show(conn, _params) do
    user = current_user(conn)
    
    bytes_used = Storage.get_storage_usage(user.id)
    
    # Convert to MB and GB
    mb_used = round(bytes_used / 1024 / 1024)
    gb_used = Float.round(bytes_used / 1024 / 1024 / 1024, 2)
    
    # Free tier: 1GB
    gb_limit = 1.0
    percent_used = min(round(gb_used / gb_limit * 100), 100)
    
    json(conn, %{
      bytes: bytes_used,
      mb: mb_used,
      gb: gb_used,
      limit_gb: gb_limit,
      percent_used: percent_used
    })
  end
end
