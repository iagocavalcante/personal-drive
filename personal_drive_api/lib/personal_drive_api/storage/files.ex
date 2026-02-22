defmodule PersonalDriveApi.Storage.Files do
  use Ecto.Schema
  import Ecto.Changeset

  schema "file" do
    field :name, :string
    field :size, :integer
    field :content_type, :string
    field :r2_key, :string
    field :r2_etag, :string
    field :is_folder, :boolean, default: false
    field :parent_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(files, attrs) do
    files
    |> cast(attrs, [:name, :size, :content_type, :r2_key, :r2_etag, :is_folder])
    |> validate_required([:name, :size, :content_type, :r2_key, :r2_etag, :is_folder])
  end
end
