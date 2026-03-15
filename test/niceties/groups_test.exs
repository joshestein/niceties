defmodule Niceties.GroupsTest do
  use Niceties.DataCase

  alias Niceties.Groups

  describe "groups" do
    alias Niceties.Groups.Group

    import Niceties.GroupsFixtures

    @invalid_attrs %{name: nil, releases_at: nil}

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Groups.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Groups.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      valid_attrs = %{name: "some name", releases_at: ~U[2026-03-14 12:52:00Z]}

      assert {:ok, %Group{} = group} = Groups.create_group(valid_attrs)
      assert group.name == "some name"
      assert group.releases_at == ~U[2026-03-14 12:52:00Z]
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      update_attrs = %{name: "some updated name", releases_at: ~U[2026-03-15 12:52:00Z]}

      assert {:ok, %Group{} = group} = Groups.update_group(group, update_attrs)
      assert group.name == "some updated name"
      assert group.releases_at == ~U[2026-03-15 12:52:00Z]
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.update_group(group, @invalid_attrs)
      assert group == Groups.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Groups.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Groups.change_group(group)
    end
  end

  describe "memberships" do
    alias Niceties.Groups.Membership

    import Niceties.GroupsFixtures

    @invalid_attrs %{role: nil}

    test "list_memberships/0 returns all memberships" do
      membership = membership_fixture()
      assert Groups.list_memberships() == [membership]
    end

    test "get_membership!/1 returns the membership with given id" do
      membership = membership_fixture()
      assert Groups.get_membership!(membership.id) == membership
    end

    test "create_membership/1 with valid data creates a membership" do
      valid_attrs = %{
        role: "admin",
        group_id: group_fixture().id,
        user_id: Niceties.AccountsFixtures.user_fixture().id
      }

      assert {:ok, %Membership{} = membership} = Groups.create_membership(valid_attrs)
      assert membership.role == "admin"
      assert membership.group_id == valid_attrs.group_id
      assert membership.user_id == valid_attrs.user_id
    end

    test "create_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_membership(@invalid_attrs)
    end

    test "update_membership/2 with valid data updates the membership" do
      membership = membership_fixture()
      update_attrs = %{role: "staff"}

      assert {:ok, %Membership{} = membership} =
               Groups.update_membership(membership, update_attrs)

      assert membership.role == "staff"
    end

    test "update_membership/2 with invalid data returns error changeset" do
      membership = membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.update_membership(membership, @invalid_attrs)
      assert membership == Groups.get_membership!(membership.id)
    end

    test "delete_membership/1 deletes the membership" do
      membership = membership_fixture()
      assert {:ok, %Membership{}} = Groups.delete_membership(membership)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_membership!(membership.id) end
    end

    test "change_membership/1 returns a membership changeset" do
      membership = membership_fixture()
      assert %Ecto.Changeset{} = Groups.change_membership(membership)
    end
  end
end
