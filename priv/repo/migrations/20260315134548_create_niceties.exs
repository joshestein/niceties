defmodule Niceties.Repo.Migrations.CreateNiceties do
  use Ecto.Migration

  def change do
    create table(:niceties) do
      add :anonymous, :boolean, default: false, null: false
      add :body, :text, null: false
      add :group_id, references(:groups, on_delete: :nothing), null: false
      add :user_from_id, references(:users, on_delete: :nothing), null: false
      add :user_to_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:niceties, [:group_id])
    create index(:niceties, [:user_from_id])
    create index(:niceties, [:user_to_id])
  end
end
