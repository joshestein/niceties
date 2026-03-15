defmodule Niceties.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :releases_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
