defmodule Niceties.NotesTest do
  use Niceties.DataCase

  alias Niceties.Notes

  describe "niceties" do
    alias Niceties.Notes.Nicety

    import Niceties.NotesFixtures

    @invalid_attrs %{body: nil, anonymous: nil}

    test "list_niceties/0 returns all niceties" do
      nicety = nicety_fixture()
      assert Notes.list_niceties() == [nicety]
    end

    test "get_nicety!/1 returns the nicety with given id" do
      nicety = nicety_fixture()
      assert Notes.get_nicety!(nicety.id) == nicety
    end

    test "create_nicety/1 with valid data creates a nicety" do
      valid_attrs = %{body: "some body", anonymous: true}

      assert {:ok, %Nicety{} = nicety} = Notes.create_nicety(valid_attrs)
      assert nicety.body == "some body"
      assert nicety.anonymous == true
    end

    test "create_nicety/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notes.create_nicety(@invalid_attrs)
    end

    test "update_nicety/2 with valid data updates the nicety" do
      nicety = nicety_fixture()
      update_attrs = %{body: "some updated body", anonymous: false}

      assert {:ok, %Nicety{} = nicety} = Notes.update_nicety(nicety, update_attrs)
      assert nicety.body == "some updated body"
      assert nicety.anonymous == false
    end

    test "update_nicety/2 with invalid data returns error changeset" do
      nicety = nicety_fixture()
      assert {:error, %Ecto.Changeset{}} = Notes.update_nicety(nicety, @invalid_attrs)
      assert nicety == Notes.get_nicety!(nicety.id)
    end

    test "delete_nicety/1 deletes the nicety" do
      nicety = nicety_fixture()
      assert {:ok, %Nicety{}} = Notes.delete_nicety(nicety)
      assert_raise Ecto.NoResultsError, fn -> Notes.get_nicety!(nicety.id) end
    end

    test "change_nicety/1 returns a nicety changeset" do
      nicety = nicety_fixture()
      assert %Ecto.Changeset{} = Notes.change_nicety(nicety)
    end
  end
end
