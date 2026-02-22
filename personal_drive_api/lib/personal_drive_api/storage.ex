defmodule PersonalDriveApi.Storage do
  @moduledoc """
  The Storage context.
  """

  import Ecto.Query, warn: false
  alias PersonalDriveApi.Repo

  alias PersonalDriveApi.Storage.Files

  @doc """
  Returns the list of file.

  ## Examples

      iex> list_file()
      [%Files{}, ...]

  """
  def list_file do
    Repo.all(Files)
  end

  @doc """
  Returns root files (no parent).
  """
  def list_root_files do
    Repo.all(from f in Files, where: is_nil(f.parent_id))
  end

  @doc """
  Returns files by parent ID.
  """
  def list_files_by_parent(parent_id) do
    Repo.all(from f in Files, where: f.parent_id == ^parent_id)
  end

  @doc """
  Gets a single files.

  Raises `Ecto.NoResultsError` if the Files does not exist.

  ## Examples

      iex> get_files!(123)
      %Files{}

      iex> get_files!(456)
      ** (Ecto.NoResultsError)

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

  ## Examples

      iex> create_files(%{field: value})
      {:ok, %Files{}}

      iex> create_files(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

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
  def create_folder(name, parent_id \\ nil) do
    create_files(%{
      name: name,
      size: 0,
      content_type: "folder",
      r2_key: nil,
      r2_etag: nil,
      is_folder: true,
      parent_id: parent_id
    })
  end

  @doc """
  Deletes a folder and all its contents recursively.
  """
  def delete_folder_recursive(folder_id) do
    # Get all children
    children = list_files_by_parent(folder_id)

    # Recursively delete each child
    Enum.each(children, fn child ->
      if child.is_folder do
        delete_folder_recursive(child.id)
      else
        delete_files(child)
      end
    end)

    # Delete the folder itself
    folder = get_file(folder_id)
    if folder, do: delete_files(folder)
  end

  @doc """
  Updates a files.

  ## Examples

      iex> update_files(files, %{field: new_value})
      {:ok, %Files{}}

      iex> update_files(files, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_files(%Files{} = files, attrs) do
    files
    |> Files.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a files.

  ## Examples

      iex> delete_files(files)
      {:ok, %Files{}}

      iex> delete_files(files)
      {:error, %Ecto.Changeset{}}

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

  ## Examples

      iex> change_files(files)
      %Ecto.Changeset{data: %Files{}}

  """
  def change_files(%Files{} = files, attrs \\ %{}) do
    Files.changeset(files, attrs)
  end
end
