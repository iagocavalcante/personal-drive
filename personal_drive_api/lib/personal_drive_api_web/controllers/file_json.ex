defmodule PersonalDriveApiWeb.FileJSON do
  alias PersonalDriveApi.Storage.Files

  def index(%{files: files}) do
    %{data: for(file <- files, do: data(file))}
  end

  def show(%{file: file}) do
    %{data: data(file)}
  end

  def error(%{changeset: changeset}) do
    %{
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  defp data(%Files{} = file) do
    %{
      id: file.id,
      name: file.name,
      size: file.size,
      content_type: file.content_type,
      r2_key: file.r2_key,
      r2_etag: file.r2_etag,
      is_folder: file.is_folder,
      parent_id: file.parent_id,
      inserted_at: file.inserted_at,
      updated_at: file.updated_at
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
