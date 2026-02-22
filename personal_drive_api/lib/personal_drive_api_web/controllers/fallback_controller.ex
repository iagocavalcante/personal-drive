defmodule PersonalDriveApiWeb.FallbackController do
  use PersonalDriveApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: PersonalDriveApiWeb.ErrorJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: PersonalDriveApiWeb.ErrorJSON)
    |> render(:"404")
  end
end
