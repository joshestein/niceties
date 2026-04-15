defmodule NicetiesWeb.GroupControllerTest do
  use NicetiesWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Niceties.AccountsFixtures
  import Niceties.GroupsFixtures

  alias Niceties.Groups
  alias Niceties.Notes

  # Helper group with two members, logged in as the first
  defp group_with_members(conn) do
    user = user_fixture()
    other_user = user_fixture()
    group = group_fixture()

    {:ok, _} =
      Groups.create_membership(%{role: "participant", group_id: group.id, user_id: user.id})

    {:ok, _} =
      Groups.create_membership(%{role: "participant", group_id: group.id, user_id: other_user.id})

    conn = log_in_user(conn, user)
    %{conn: conn, user: user, other_user: other_user, group: group}
  end

  describe "authentication" do
    test "unauthenticated user is redirected to login for index", %{conn: conn} do
      conn = get(conn, ~p"/groups")
      assert redirected_to(conn) == ~p"/users/log-in"
    end

    test "unauthenticated user is redirected to login for group page", %{conn: conn} do
      group = group_fixture()
      conn = get(conn, ~p"/groups/#{group.id}")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "GET /groups" do
    test "shows only the groups the current user belongs to", %{conn: conn} do
      %{conn: conn, group: group} = group_with_members(conn)
      other_group = group_fixture(%{name: "Other Group"})

      conn = get(conn, ~p"/groups")
      html = html_response(conn, 200)

      assert html =~ group.name
      refute html =~ other_group.name
    end

    test "shows all groups for a user with multiple memberships", %{conn: conn} do
      user = user_fixture()
      group_a = group_fixture(%{name: "Group A"})
      group_b = group_fixture(%{name: "Group B"})

      {:ok, _} =
        Groups.create_membership(%{role: "participant", group_id: group_a.id, user_id: user.id})

      {:ok, _} =
        Groups.create_membership(%{role: "participant", group_id: group_b.id, user_id: user.id})

      conn = conn |> log_in_user(user) |> get(~p"/groups")
      html = html_response(conn, 200)

      assert html =~ "Group A"
      assert html =~ "Group B"
    end
  end

  describe "GET /groups/:id" do
    test "shows the group page with nicety forms for other members", %{conn: conn} do
      %{conn: conn, other_user: other_user, group: group} = group_with_members(conn)

      conn = get(conn, ~p"/groups/#{group.id}")
      html = html_response(conn, 200)

      assert html =~ other_user.name
      assert html =~ "<form"
    end

    test "redirects non-member to /groups", %{conn: conn} do
      outsider = user_fixture()
      group = group_fixture()

      conn = conn |> log_in_user(outsider) |> get(~p"/groups/#{group.id}")
      assert redirected_to(conn) == ~p"/groups"
    end

    test "shows locked message when group is not released and has no release date", %{conn: conn} do
      user = user_fixture()
      group = group_fixture(%{releases_at: nil})

      {:ok, _} =
        Groups.create_membership(%{role: "participant", group_id: group.id, user_id: user.id})

      conn = conn |> log_in_user(user) |> get(~p"/groups/#{group.id}")
      assert html_response(conn, 200) =~ "released soon"
    end

    test "shows scheduled release date when releases_at is in the future", %{conn: conn} do
      user = user_fixture()
      future = DateTime.add(DateTime.utc_now(), 30, :day)
      group = group_fixture(%{releases_at: future})

      {:ok, _} =
        Groups.create_membership(%{role: "participant", group_id: group.id, user_id: user.id})

      conn = conn |> log_in_user(user) |> get(~p"/groups/#{group.id}")
      html = html_response(conn, 200)

      assert html =~ Calendar.strftime(future, "%B")
    end

    test "shows received niceties when group is released", %{conn: conn} do
      %{conn: conn, user: user, other_user: other_user, group: group} = group_with_members(conn)

      {:ok, _} =
        Notes.upsert_nicety(%{
          body: "you are wonderful",
          anonymous: false,
          group_id: group.id,
          user_from_id: other_user.id,
          user_to_id: user.id
        })

      {:ok, group} = Groups.update_group(group, %{released: true})

      conn = get(conn, ~p"/groups/#{group.id}")
      assert html_response(conn, 200) =~ "you are wonderful"
    end

    test "shows given niceties as text (no form) after group is released", %{conn: conn} do
      %{conn: conn, user: user, other_user: other_user, group: group} = group_with_members(conn)

      {:ok, _} =
        Notes.upsert_nicety(%{
          body: "you are great",
          anonymous: false,
          group_id: group.id,
          user_from_id: user.id,
          user_to_id: other_user.id
        })

      {:ok, group} = Groups.update_group(group, %{released: true})

      conn = get(conn, ~p"/groups/#{group.id}")
      html = html_response(conn, 200)

      refute html =~ "<form"
      assert html =~ "you are great"
    end

    test "hides sender name for anonymous niceties after release", %{conn: conn} do
      user = user_fixture(%{name: "Recipient Person"})
      other_user = user_fixture(%{name: "Secret Sender"})
      group = group_fixture()

      {:ok, _} =
        Groups.create_membership(%{role: "participant", group_id: group.id, user_id: user.id})

      {:ok, _} =
        Groups.create_membership(%{
          role: "participant",
          group_id: group.id,
          user_id: other_user.id
        })

      conn = log_in_user(conn, user)

      {:ok, _} =
        Notes.upsert_nicety(%{
          body: "secret admirer nicety",
          anonymous: true,
          group_id: group.id,
          user_from_id: other_user.id,
          user_to_id: user.id
        })

      {:ok, group} = Groups.update_group(group, %{released: true})

      conn = get(conn, ~p"/groups/#{group.id}")
      html = html_response(conn, 200)

      assert html =~ "secret admirer nicety"
      # The received section should show "Anonymous", not the sender's name beside the nicety
      document = LazyHTML.from_fragment(html)
      received_section = LazyHTML.query(document, "[id^=received-]")
      received_text = LazyHTML.text(received_section)
      assert received_text =~ "Anonymous"
      refute received_text =~ "Secret Sender"
    end
  end

  describe "save_nicety event" do
    test "saves a nicety", %{conn: conn} do
      %{conn: conn, user: user, other_user: other_user, group: group} = group_with_members(conn)

      {:ok, lv, _html} = live(conn, ~p"/groups/#{group.id}")

      lv
      |> form("#form-user-#{other_user.id}",
        nicety: %{body: "great collaborator", anonymous: false}
      )
      |> render_change()

      assert [nicety] = Notes.get_given(Niceties.Accounts.Scope.for_user(user), group.id)
      assert nicety.body == "great collaborator"
    end

    test "updating a nicety replaces the previous one (upsert)", %{conn: conn} do
      %{conn: conn, user: user, other_user: other_user, group: group} = group_with_members(conn)

      {:ok, lv, _html} = live(conn, ~p"/groups/#{group.id}")

      lv
      |> form("#form-user-#{other_user.id}", nicety: %{body: "first draft", anonymous: false})
      |> render_change()

      lv
      |> form("#form-user-#{other_user.id}", nicety: %{body: "final version", anonymous: false})
      |> render_change()

      niceties = Notes.get_given(Niceties.Accounts.Scope.for_user(user), group.id)
      assert length(niceties) == 1
      assert hd(niceties).body == "final version"
    end

    test "shows validation error when body is blank", %{conn: conn} do
      %{conn: conn, other_user: other_user, group: group} = group_with_members(conn)

      {:ok, lv, _html} = live(conn, ~p"/groups/#{group.id}")

      html =
        lv
        |> form("#form-user-#{other_user.id}", nicety: %{body: "", anonymous: false})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end
  end
end
