defmodule Niceties.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :releases_at, :utc_datetime
    has_many :memberships, Niceties.Groups.Membership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :releases_at])
    |> validate_required([:name, :releases_at])
  end
end
