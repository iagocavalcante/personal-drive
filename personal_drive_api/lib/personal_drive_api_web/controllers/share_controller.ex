defmodule PersonalDriveApiWeb.ShareController do
  use PersonalDriveApiWeb, :controller

  alias PersonalDriveApi.Storage

  defp current_user(conn) do
    conn.assigns[:current_user]
  end

  # Share a file with another user
  def share(conn, %{"file_id" => file_id, "email" => email}) do
    user = current_user(conn)
    
    # Verify file exists and user owns it
    file = Storage.get_file!(file_id)
    
    if file.user_id != user.id do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not authorized"})
    else
      case Storage.share_file(file_id, email, user.id) do
        {:ok, share} ->
          json(conn, %{success: true, share_id: share.id})

        {:error, :user_not_found} ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "User not found"})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Failed to share file"})
      end
    end
  end

  # List files shared with current user
  def shared_with_me(conn, _params) do
    user = current_user(conn)
    
    shares = Storage.list_shared_with_user(user.id)
    
    files = Enum.map(shares, fn share ->
      %{
        id: share.file.id,
        name: share.file.name,
        size: share.file.size,
        content_type: share.file.content_type,
        is_folder: share.file.is_folder,
        shared_by: share.shared_by.email,
        permission: share.permission
      }
    end)
    
    json(conn, %{data: files})
  end

  # List files shared by current user
  def shared_by_me(conn, _params) do
    user = current_user(conn)
    
    shares = Storage.list_shared_by_user(user.id)
    
    files = Enum.map(shares, fn share ->
      %{
        id: share.file.id,
        name: share.file.name,
        size: share.file.size,
        content_type: share.file.content_type,
        is_folder: share.file.is_folder,
        shared_with: share.shared_by_user_id,
        permission: share.permission
      }
    end)
    
    json(conn, %{data: files})
  end

  # Delete a share
  def unshare(conn, %{"id" => id}) do
    user = current_user(conn)
    
    share = Storage.get_share!(id)
    
    # Only the owner can unshare
    if share.shared_by_user_id != user.id do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not authorized"})
    else
      case Storage.delete_share(share) do
        {:ok, _} ->
          json(conn, %{success: true})

        {:error, _} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Failed to unshare"})
      end
    end
  end
end
