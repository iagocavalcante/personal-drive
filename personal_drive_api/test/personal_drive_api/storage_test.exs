defmodule PersonalDriveApi.StorageTest do
  use PersonalDriveApi.DataCase

  alias PersonalDriveApi.Storage

  describe "file" do
    alias PersonalDriveApi.Storage.Files

    import PersonalDriveApi.StorageFixtures

    @invalid_attrs %{name: nil, size: nil, content_type: nil, r2_key: nil, r2_etag: nil, is_folder: nil}

    test "list_file/0 returns all file" do
      files = files_fixture()
      assert Storage.list_file() == [files]
    end

    test "get_files!/1 returns the files with given id" do
      files = files_fixture()
      assert Storage.get_files!(files.id) == files
    end

    test "create_files/1 with valid data creates a files" do
      valid_attrs = %{name: "some name", size: 42, content_type: "some content_type", r2_key: "some r2_key", r2_etag: "some r2_etag", is_folder: true}

      assert {:ok, %Files{} = files} = Storage.create_files(valid_attrs)
      assert files.name == "some name"
      assert files.size == 42
      assert files.content_type == "some content_type"
      assert files.r2_key == "some r2_key"
      assert files.r2_etag == "some r2_etag"
      assert files.is_folder == true
    end

    test "create_files/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Storage.create_files(@invalid_attrs)
    end

    test "update_files/2 with valid data updates the files" do
      files = files_fixture()
      update_attrs = %{name: "some updated name", size: 43, content_type: "some updated content_type", r2_key: "some updated r2_key", r2_etag: "some updated r2_etag", is_folder: false}

      assert {:ok, %Files{} = files} = Storage.update_files(files, update_attrs)
      assert files.name == "some updated name"
      assert files.size == 43
      assert files.content_type == "some updated content_type"
      assert files.r2_key == "some updated r2_key"
      assert files.r2_etag == "some updated r2_etag"
      assert files.is_folder == false
    end

    test "update_files/2 with invalid data returns error changeset" do
      files = files_fixture()
      assert {:error, %Ecto.Changeset{}} = Storage.update_files(files, @invalid_attrs)
      assert files == Storage.get_files!(files.id)
    end

    test "delete_files/1 deletes the files" do
      files = files_fixture()
      assert {:ok, %Files{}} = Storage.delete_files(files)
      assert_raise Ecto.NoResultsError, fn -> Storage.get_files!(files.id) end
    end

    test "change_files/1 returns a files changeset" do
      files = files_fixture()
      assert %Ecto.Changeset{} = Storage.change_files(files)
    end
  end
end
