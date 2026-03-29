defmodule Niceties.Repo.Migrations.AddGroupReleasedField do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :released, :boolean, default: false, null: false
    end
  end
end
