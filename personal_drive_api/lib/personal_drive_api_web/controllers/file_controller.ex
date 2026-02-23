defmodule PersonalDriveApiWeb.FileController do
  use PersonalDriveApiWeb, :controller

  alias PersonalDriveApi.Storage
  alias PersonalDriveApi.Storage.Files
  alias PersonalDriveApi.Storage.R2

  action_fallback PersonalDriveApiWeb.FallbackController

  # Get current user from Pow assigns
  defp current_user(conn) do
    conn.assigns[:current_user]
  end

  # List files (root or folder)
  def index(conn, %{"parent_id" => parent_id}) do
    user = current_user(conn)
    files = Storage.list_files_by_parent(parent_id, user.id)
    render(conn, :index, files: files)
  end

  def index(conn, _params) do
    user = current_user(conn)
    files = Storage.list_root_files(user.id)
    render(conn, :index, files: files)
  end

  # Get single file/folder
  def show(conn, %{"id" => id}) do
    user = current_user(conn)
    file = Storage.get_file!(id)
    
    # Verify ownership
    if file.user_id == user.id do
      render(conn, :show, file: file)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not authorized"})
    end
  end

  # Create folder
  def create_folder(conn, %{"name" => name, "parent_id" => parent_id}) do
    user = current_user(conn)
    
    case Storage.create_folder(name, user.id, parent_id) do
      {:ok, folder} ->
        conn
        |> put_status(:created)
        |> render(:show, file: folder)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def create_folder(conn, %{"name" => name}) do
    create_folder(conn, %{"name" => name, "parent_id" => nil})
  end

  # Upload file
  def upload(conn, %{"file" => file, "parent_id" => parent_id}) do
    user = current_user(conn)
    upload_file(conn, file, parent_id, user.id)
  end

  def upload(conn, %{"file" => file}) do
    user = current_user(conn)
    upload_file(conn, file, nil, user.id)
  end

  defp upload_file(conn, file, parent_id, user_id) do
    filename = file.filename
    content_type = file.content_type
    {:ok, binary} = File.read(file.path)

    key = R2.generate_key(parent_id, filename)

    case R2.upload_binary(binary, key, content_type) do
      {:ok, r2_data} ->
        case Storage.create_file(%{
              name: filename,
              size: byte_size(binary),
              content_type: content_type,
              r2_key: r2_data.r2_key,
              r2_etag: r2_data.r2_etag,
              is_folder: false,
              parent_id: parent_id,
              user_id: user_id
            }) do
          {:ok, file_record} ->
            conn
            |> put_status(:created)
            |> render(:show, file: file_record)

          {:error, changeset} ->
            R2.delete_file(key)
            conn
            |> put_status(:unprocessable_entity)
            |> render(:error, changeset: changeset)
        end

      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Upload failed: #{inspect(error)}"})
    end
  end

  # Get signed upload URL
  def presigned_upload(conn, %{"filename" => filename, "content_type" => content_type, "parent_id" => parent_id}) do
    key = R2.generate_key(parent_id, filename)

    case R2.get_upload_url(key, content_type) do
      {:ok, url} ->
        json(conn, %{upload_url: url, key: key})

      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to get upload URL: #{inspect(error)}"})
    end
  end

  # Confirm upload
  def confirm_upload(conn, %{"key" => key, "name" => name, "size" => size, "content_type" => content_type, "parent_id" => parent_id}) do
    user = current_user(conn)
    
    case Storage.create_file(%{
          name: name,
          size: size,
          content_type: content_type,
          r2_key: key,
          r2_etag: "pending",
          is_folder: false,
          parent_id: parent_id,
          user_id: user.id
        }) do
      {:ok, file_record} ->
        conn
        |> put_status(:created)
        |> render(:show, file: file_record)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  # Get signed download URL
  def download_url(conn, %{"id" => id}) do
    user = current_user(conn)
    file = Storage.get_file!(id)

    if file.user_id != user.id do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not authorized"})
    else
      if file.is_folder do
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Cannot download folder"})
      else
        case R2.get_signed_url(file.r2_key) do
          {:ok, url} ->
            json(conn, %{download_url: url})

          {:error, error} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to get download URL: #{inspect(error)}"})
        end
      end
    end
  end

  # Delete file/folder
  def delete(conn, %{"id" => id}) do
    user = current_user(conn)
    file = Storage.get_file!(id)

    if file.user_id != user.id do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not authorized"})
    else
      unless file.is_folder do
        R2.delete_file(file.r2_key)
      end

      if file.is_folder do
        Storage.delete_folder_recursive(id)
      end

      case Storage.delete_file(file) do
        {:ok, _} ->
          send_resp(conn, :no_content, "")

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(:error, changeset: changeset)
      end
    end
  end
end
