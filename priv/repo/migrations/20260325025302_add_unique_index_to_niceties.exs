defmodule Niceties.Repo.Migrations.AddUniqueIndexToNiceties do
  use Ecto.Migration

  def change do
    execute("""
      DELETE FROM niceties
      WHERE id NOT IN (
        SELECT DISTINCT ON (user_from_id, user_to_id, group_id) id
        FROM niceties
        ORDER BY user_from_id, user_to_id, group_id, updated_at DESC
      )
    """, "")

    create unique_index(:niceties, [:user_from_id, :user_to_id, :group_id])
  end
end
