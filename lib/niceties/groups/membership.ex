defmodule Niceties.Groups.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    field :role, :string
    belongs_to :group, Niceties.Groups.Group
    belongs_to :user, Niceties.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :group_id, :user_id])
    |> validate_required([:role, :group_id, :user_id])
    |> validate_inclusion(:role, ["admin", "staff", "participant"])
    |> unique_constraint([:group_id, :user_id])
  end
end
