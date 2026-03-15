defmodule Niceties.NotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Niceties.Notes` context.
  """

  @doc """
  Generate a nicety.
  """
  def nicety_fixture(attrs \\ %{}) do
    {:ok, nicety} =
      attrs
      |> Enum.into(%{
        anonymous: true,
        body: "some body"
      })
      |> Niceties.Notes.create_nicety()

    nicety
  end
end
