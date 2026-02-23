defmodule PersonalDriveApi.Storage.Files do
  use Ecto.Schema
  import Ecto.Changeset

  alias PersonalDriveApi.Users.User

  schema "file" do
    field :name, :string
    field :size, :integer
    field :content_type, :string
    field :r2_key, :string
    field :r2_etag, :string
    field :is_folder, :boolean, default: false
    field :parent_id, :id

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(files, attrs) do
    files
    |> cast(attrs, [:name, :size, :content_type, :r2_key, :r2_etag, :is_folder, :parent_id, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_required_if_file([:size, :content_type, :r2_key])
  end

  defp validate_required_if_file(changeset, fields) do
    if get_change(changeset, :is_folder) do
      changeset
    else
      validate_required(changeset, fields)
    end
  end
end
