defmodule Niceties.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users) do
      add :email, :citext, null: false
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
