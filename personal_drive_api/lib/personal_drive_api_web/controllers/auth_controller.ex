defmodule PersonalDriveApiWeb.AuthController do
  use PersonalDriveApiWeb, :controller

  alias PersonalDriveApi.Users
  alias PersonalDriveApiWeb.Pow.Session

  action_fallback PersonalDriveApiWeb.FallbackController

  # Register new user
  def register(conn, %{"email" => email, "password" => password}) do
    case Users.create_user(%{email: email, password_hash: password}) do
      {:ok, user} ->
        # Auto-login after registration
        conn
        |> put_session(:user_id, user.id)
        |> json(%{success: true, user: %{email: user.email}})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Registration failed"})
    end
  end

  # Login with email/password
  def login(conn, %{"email" => email, "password" => password}) do
    case Users.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> json(%{success: true, user: %{email: user.email}})

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  # Logout
  def logout(conn, _params) do
    conn
    |> clear_session()
    |> json(%{success: true})
  end

  # Get current user
  def me(conn, _params) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Not authenticated"})

      user ->
        json(conn, %{user: %{email: user.email}})
    end
  end
end
