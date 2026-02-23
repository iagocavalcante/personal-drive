defmodule PersonalDriveApiWeb.HealthController do
  use PersonalDriveApiWeb, :controller

  def show(conn, _params) do
    json(conn, %{status: "ok", timestamp: DateTime.utc_now()})
  end
end
