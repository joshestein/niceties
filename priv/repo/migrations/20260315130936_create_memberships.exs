defmodule Niceties.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :role, :string
      add :group_id, references(:groups, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:group_id])
    create index(:memberships, [:user_id])
    create unique_index(:memberships, [:group_id, :user_id])
  end
end
