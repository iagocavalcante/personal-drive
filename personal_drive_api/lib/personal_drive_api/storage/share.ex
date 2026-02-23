defmodule PersonalDriveApi.Storage.Share do
  use Ecto.Schema
  import Ecto.Changeset

  alias PersonalDriveApi.Users.User
  alias PersonalDriveApi.Storage.Files

  schema "file_shares" do
    field :permission, :string, default: "view"
    
    belongs_to :file, Files
    belongs_to :user, User, foreign_key: :shared_with_user_id
    belongs_to :shared_by, User, foreign_key: :shared_by_user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(share, attrs) do
    share
    |> cast(attrs, [:file_id, :shared_with_user_id, :shared_by_user_id, :permission])
    |> validate_required([:file_id, :shared_with_user_id, :shared_by_user_id])
    |> validate_inclusion(:permission, ["view", "edit"])
  end
end
