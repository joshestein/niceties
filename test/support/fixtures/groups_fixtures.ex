defmodule Niceties.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Niceties.Groups` context.
  """

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        name: "some name",
        releases_at: ~U[2026-03-14 12:52:00Z]
      })
      |> Niceties.Groups.create_group()

    group
  end

  @doc """
  Generate a membership.
  """
  def membership_fixture(attrs \\ %{}) do
    {:ok, membership} =
      attrs
      |> Enum.into(%{
        role: "some role"
      })
      |> Niceties.Groups.create_membership()

    membership
  end
end
