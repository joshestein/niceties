defmodule Niceties.Notes.Nicety do
  use Ecto.Schema
  import Ecto.Changeset

  schema "niceties" do
    field :anonymous, :boolean, default: false
    field :body, :string
    belongs_to :group, Niceties.Groups.Group
    belongs_to :user_from, Niceties.Accounts.User, foreign_key: :user_from_id
    belongs_to :user_to, Niceties.Accounts.User, foreign_key: :user_to_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(nicety, attrs) do
    nicety
    |> cast(attrs, [:anonymous, :body, :group_id, :user_from_id, :user_to_id])
    |> validate_required([:anonymous, :body, :group_id, :user_from_id, :user_to_id])
  end
end
