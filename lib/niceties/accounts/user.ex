defmodule Niceties.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    has_many :memberships, Niceties.Groups.Membership
    has_many :niceties_from, Niceties.Notes.Nicety, foreign_key: :user_from_id
    has_many :niceties_to, Niceties.Notes.Nicety, foreign_key: :user_to_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> unique_constraint(:email)
  end
end
