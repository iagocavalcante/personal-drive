defmodule PersonalDriveApi.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias PersonalDriveApi.Repo

  alias PersonalDriveApi.Users.User

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Authenticates a user by email and password.
  """
  def authenticate_user(email, password) do
    with %User{} = user <- get_user_by_email(email),
         true <- Pow.Ecto.Schema.Password.pbkdf2_verify(password, user.password_hash) do
      {:ok, user}
    else
      _ -> {:error, :invalid_credentials}
    end
  end
end
