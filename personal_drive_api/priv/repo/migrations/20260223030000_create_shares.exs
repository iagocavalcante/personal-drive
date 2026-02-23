defmodule PersonalDriveApi.Repo.Migrations.CreateSharesTable do
  use Ecto.Migration

  def change do
    create table(:file_shares) do
      add :file_id, references(:file, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :shared_by_user_id, references(:users, on_delete: :delete_all), null: false
      add :permission, :string, default: "view"  # "view" or "edit"

      timestamps(type: :utc_datetime)
    end

    create index(:file_shares, [:file_id])
    create index(:file_shares, [:user_id])
    create index(:file_shares, [:shared_by_user_id])
  end
end
