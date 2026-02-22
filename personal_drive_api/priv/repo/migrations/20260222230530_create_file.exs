defmodule PersonalDriveApi.Repo.Migrations.CreateFile do
  use Ecto.Migration

  def change do
    create table(:file) do
      add :name, :string
      add :size, :integer
      add :content_type, :string
      add :r2_key, :string
      add :r2_etag, :string
      add :is_folder, :boolean, default: false, null: false
      add :parent_id, references(:files, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:file, [:parent_id])
  end
end
