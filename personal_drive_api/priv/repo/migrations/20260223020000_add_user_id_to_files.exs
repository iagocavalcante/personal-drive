defmodule PersonalDriveApi.Repo.Migrations.AddUserIdToFiles do
  use Ecto.Migration

  def change do
    alter table(:file) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:file, [:user_id])
  end
end
