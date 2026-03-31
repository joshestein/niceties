defmodule Niceties.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :released, :boolean, default: false
    field :releases_at, :utc_datetime
    has_many :memberships, Niceties.Groups.Membership
    has_many :niceties, Niceties.Notes.Nicety

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :releases_at, :released])
    |> validate_required([:name])
  end
end
