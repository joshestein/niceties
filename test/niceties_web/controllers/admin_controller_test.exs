defmodule NicetiesWeb.AdminControllerTest do
  use NicetiesWeb.ConnCase, async: true

  import Niceties.AccountsFixtures
  import Niceties.GroupsFixtures

  alias Niceties.Groups

  defp admin_with_group(conn) do
    user = user_fixture()
    group = group_fixture()
    {:ok, _} = Groups.create_membership(%{role: "admin", group_id: group.id, user_id: user.id})
    conn = log_in_user(conn, user)
    %{conn: conn, user: user, group: group}
  end

  describe "authentication" do
    test "unauthenticated user is redirected to login", %{conn: conn} do
      conn = get(conn, ~p"/admin/groups")
      assert redirected_to(conn) == ~p"/users/log-in"
    end

    test "non-admin user is redirected to /groups", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user) |> get(~p"/admin/groups")
      assert redirected_to(conn) == ~p"/groups"
    end
  end

  describe "GET /admin/groups" do
    test "lists all groups and shows creation form", %{conn: conn} do
      %{conn: conn, group: group} = admin_with_group(conn)

      conn = get(conn, ~p"/admin/groups")
      html = html_response(conn, 200)

      assert html =~ group.name
      assert html =~ "Create new group"
    end
  end

  describe "POST /admin/groups" do
    test "creates group and redirects to group page", %{conn: conn} do
      %{conn: conn} = admin_with_group(conn)

      conn =
        post(conn, ~p"/admin/groups", %{
          "group" => %{"name" => "Test Cohort", "releases_at" => ""}
        })

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/groups/#{id}"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Successfully created"
      group = Groups.get_group!(id)
      assert group.name == "Test Cohort"
      assert is_nil(group.releases_at)
    end

    test "returns error when name is missing", %{conn: conn} do
      %{conn: conn} = admin_with_group(conn)

      conn =
        post(conn, ~p"/admin/groups", %{
          "group" => %{"name" => "", "releases_at" => ""}
        })

      assert html_response(conn, 200) =~ "Create new group"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Failed to create"
    end
  end

  describe "GET /admin/groups/:id" do
    test "shows group detail with member list", %{conn: conn} do
      %{conn: conn, group: group} = admin_with_group(conn)
      member = user_fixture()
      {:ok, _} = Groups.create_membership(%{role: "participant", group_id: group.id, user_id: member.id})

      conn = get(conn, ~p"/admin/groups/#{group.id}")
      html = html_response(conn, 200)

      assert html =~ group.name
      assert html =~ member.name
      assert html =~ member.email
      assert html =~ "Invite user"
    end

    test "non-admin of this specific group is redirected", %{conn: conn} do
      user = user_fixture()
      other_group = group_fixture()
      # user is admin of other_group but not this one
      {:ok, _} = Groups.create_membership(%{role: "admin", group_id: other_group.id, user_id: user.id})
      target_group = group_fixture()

      conn = conn |> log_in_user(user) |> get(~p"/admin/groups/#{target_group.id}")
      assert redirected_to(conn) == ~p"/groups"
    end
  end

  describe "POST /admin/groups/:id/members" do
    test "creates a new user, membership, and sends invitation email", %{conn: conn} do
      %{conn: conn, group: group} = admin_with_group(conn)

      conn =
        post(conn, ~p"/admin/groups/#{group.id}/members", %{
          "membership" => %{
            "name" => "New Fellow",
            "email" => "newfellow@example.com",
            "role" => "participant"
          }
        })

      assert redirected_to(conn) == ~p"/admin/groups/#{group.id}"

      memberships = Groups.get_all_memberships(group)
      emails = Enum.map(memberships, & &1.user.email)
      assert "newfellow@example.com" in emails
    end

    test "adds existing user to group without creating a duplicate account", %{conn: conn} do
      %{conn: conn, group: group} = admin_with_group(conn)
      existing_user = user_fixture(%{name: "Existing Person"})

      post(conn, ~p"/admin/groups/#{group.id}/members", %{
        "membership" => %{
          "name" => existing_user.name,
          "email" => existing_user.email,
          "role" => "participant"
        }
      })

      memberships = Groups.get_all_memberships(group)
      member_user_ids = Enum.map(memberships, & &1.user_id)
      assert existing_user.id in member_user_ids
    end

    test "shows error when email is missing", %{conn: conn} do
      %{conn: conn, group: group} = admin_with_group(conn)

      conn =
        post(conn, ~p"/admin/groups/#{group.id}/members", %{
          "membership" => %{"name" => "Bad", "email" => "", "role" => "participant"}
        })

      assert html_response(conn, 200) =~ "Invite user"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Failed to create"
    end
  end

  describe "POST /admin/groups/:id/release" do
    test "marks group as released and redirects", %{conn: conn} do
      %{conn: conn, group: group} = admin_with_group(conn)

      conn =
        post(conn, ~p"/admin/groups/#{group.id}/release", %{"return_to" => ~p"/admin/groups"})

      assert redirected_to(conn) == ~p"/admin/groups"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "released"
      assert Groups.get_group!(group.id).released == true
    end

    test "redirects safely if return_to is an external URL", %{conn: conn} do
      %{conn: conn, group: group} = admin_with_group(conn)

      conn =
        post(conn, ~p"/admin/groups/#{group.id}/release", %{
          "return_to" => "https://evil.com"
        })

      assert redirected_to(conn) == ~p"/admin/groups"
    end
  end
end
