defmodule Niceties.NotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Niceties.Notes` context.
  """

  @doc """
  Generate a nicety.
  """
  def nicety_fixture(attrs \\ %{}) do
    group = Niceties.GroupsFixtures.group_fixture()
    user_from = Niceties.AccountsFixtures.user_fixture()
    user_to = Niceties.AccountsFixtures.user_fixture()

    {:ok, nicety} =
      attrs
      |> Enum.into(%{
        anonymous: true,
        body: "some body",
        group_id: group.id,
        user_from_id: user_from.id,
        user_to_id: user_to.id
      })
      |> Niceties.Notes.create_nicety()

    nicety
  end
end
