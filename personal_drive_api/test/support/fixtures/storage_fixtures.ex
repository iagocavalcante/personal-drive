defmodule PersonalDriveApi.StorageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PersonalDriveApi.Storage` context.
  """

  @doc """
  Generate a files.
  """
  def files_fixture(attrs \\ %{}) do
    {:ok, files} =
      attrs
      |> Enum.into(%{
        content_type: "some content_type",
        is_folder: true,
        name: "some name",
        r2_etag: "some r2_etag",
        r2_key: "some r2_key",
        size: 42
      })
      |> PersonalDriveApi.Storage.create_files()

    files
  end
end
