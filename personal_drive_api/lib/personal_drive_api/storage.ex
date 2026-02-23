defmodule PersonalDriveApi.Storage do
  @moduledoc """
  The Storage context.
  """

  import Ecto.Query, warn: false
  alias PersonalDriveApi.Repo

  alias PersonalDriveApi.Storage.Files
  alias PersonalDriveApi.Storage.Share

  # ===== FILES =====

  @doc """
  Returns the list of files for a user.
  """
  def list_files(user_id) do
    Repo.all(from f in Files, where: f.user_id == ^user_id)
  end

  @doc """
  Returns root files (no parent) for a user.
  """
  def list_root_files(user_id) do
    Repo.all(from f in Files, where: f.user_id == ^user_id and is_nil(f.parent_id))
  end

  @doc """
  Returns files by parent ID for a user.
  """
  def list_files_by_parent(parent_id, user_id) do
    Repo.all(from f in Files, where: f.parent_id == ^parent_id and f.user_id == ^user_id)
  end

  @doc """
  Gets a single files.
  """
  def get_files!(id), do: Repo.get!(Files, id)

  @doc """
  Gets a single files by id (returns nil if not found).
  """
  def get_file(id), do: Repo.get(Files, id)

  @doc """
  Gets a single files! (raises if not found).
  """
  def get_file!(id), do: Repo.get!(Files, id)

  @doc """
  Creates a files.
  """
  def create_files(attrs \\ %{}) do
    %Files{}
    |> Files.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a file (alias for create_files).
  """
  def create_file(attrs \\ %{}) do
    create_files(attrs)
  end

  @doc """
  Creates a folder.
  """
  def create_folder(name, user_id, parent_id \\ nil) do
    create_files(%{
      name: name,
      size: 0,
      content_type: "folder",
      r2_key: nil,
      r2_etag: nil,
      is_folder: true,
      parent_id: parent_id,
      user_id: user_id
    })
  end

  @doc """
  Deletes a folder and all its contents recursively.
  """
  def delete_folder_recursive(folder_id) do
    children = list_files_by_parent(folder_id, nil)

    Enum.each(children, fn child ->
      if child.is_folder do
        delete_folder_recursive(child.id)
      else
        delete_files(child)
      end
    end)

    folder = get_file(folder_id)
    if folder, do: delete_files(folder)
  end

  @doc """
  Updates a files.
  """
  def update_files(%Files{} = files, attrs) do
    files
    |> Files.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a files.
  """
  def delete_files(%Files{} = files) do
    Repo.delete(files)
  end

  @doc """
  Alias for delete_files.
  """
  def delete_file(%Files{} = files) do
    delete_files(files)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking files changes.
  """
  def change_files(%Files{} = files, attrs \\ %{}) do
    Files.changeset(files, attrs)
  end

  # ===== SHARING =====

  @doc """
  Share a file with another user.
  """
  def share_file(file_id, shared_with_email, shared_by_user_id, permission \\ "view") do
    # Get user by email
    case Repo.get_by(User, email: shared_with_email) do
      nil ->
        {:error, :user_not_found}

      shared_with_user ->
        # Check if already shared
        existing = Repo.one(from s in Share, 
          where: s.file_id == ^file_id and s.shared_with_user_id == ^shared_with_user.id,
          preload: [:file])

        if existing do
          {:ok, existing}
        else
          %Share{}
          |> Share.changeset(%{
            file_id: file_id,
            shared_with_user_id: shared_with_user.id,
            shared_by_user_id: shared_by_user_id,
            permission: permission
          })
          |> Repo.insert()
        end
    end
  end

  @doc """
  Get files shared with a user.
  """
  def list_shared_with_user(user_id) do
    Repo.all(from s in Share, 
      where: s.shared_with_user_id == ^user_id,
      preload: [:file, :shared_by])
  end

  @doc """
  Get files shared by a user.
  """
  def list_shared_by_user(user_id) do
    Repo.all(from s in Share, 
      where: s.shared_by_user_id == ^user_id,
      preload: [:file, :shared_by])
  end

  @doc """
  Delete a share.
  """
  def delete_share(%Share{} = share) do
    Repo.delete(share)
  end

  @doc """
  Get a share by ID.
  """
  def get_share!(id), do: Repo.get!(Share, id)

  # ===== USAGE =====

  @doc """
  Get total storage used by a user.
  """
  def get_storage_usage(user_id) do
    result = Repo.one(from f in Files, 
      where: f.user_id == ^user_id and f.is_folder == false,
      select: sum(f.size))
    
    result || 0
  end
end
