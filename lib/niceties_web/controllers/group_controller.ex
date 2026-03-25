defmodule NicetiesWeb.GroupController do
  use NicetiesWeb, :controller
  import Phoenix.Component, only: [to_form: 1]

  alias Niceties.Groups
  alias Niceties.Notes
  alias Niceties.Notes.Nicety

  def index(conn, _params) do
    groups = Groups.list_groups_for_user(conn.assigns.current_scope)
    render(conn, :index, groups: groups)
  end

  def group(conn, %{"id" => id}) do
    if Groups.member_of_group?(conn.assigns.current_scope.user.id, id) do
      render(conn, :group, group_assigns(conn, id))
    else
      conn
      |> redirect(to: ~p"/groups")
      |> halt()
    end
  end

  def create_nicety(conn, %{"id" => group_id, "user_id" => user_to_id} = params) do
    nicety_params = %{
      "body" => params["body"],
      "anonymous" => params["anonymous"],
      "user_from_id" => conn.assigns.current_scope.user.id,
      "user_to_id" => user_to_id,
      "group_id" => group_id
    }

    case Notes.upsert_nicety(nicety_params) do
      {:ok, _nicety} ->
        redirect(conn, to: ~p"/groups/#{group_id}")

      {:error, _changeset} ->
        conn |> put_flash(:error, "Failed to create nicety") |> redirect(to: ~p"/groups/#{group_id}")
    end
  end

  defp group_assigns(conn, id) do
    given = Notes.get_given(conn.assigns.current_scope, id)
    given_map = Map.new(given, fn nicety -> {nicety.user_to_id, nicety} end)
    members = Groups.get_all_memberships(id)

    users = Enum.map(members, fn member -> member.user end)

    other_users =
      Enum.filter(users, fn user -> user.id != conn.assigns.current_scope.user.id end)

    forms =
      Map.new(other_users, fn user ->
        nicety = Map.get(given_map, user.id, %Nicety{})
        {user.id, to_form(Notes.change_nicety(nicety))}
      end)

    %{
      id: id,
      users: other_users,
      forms: forms
    }
  end
end
