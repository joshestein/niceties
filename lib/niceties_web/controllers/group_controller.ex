defmodule NicetiesWeb.GroupController do
  use NicetiesWeb, :controller

  alias Niceties.Groups
  alias Niceties.Notes

  def index(conn, _params) do
    groups = Groups.list_groups_for_user(conn.assigns.current_scope)
    render(conn, :index, groups: groups)
  end

  def group(conn, %{"id" => id}) do
    unless Groups.member_of_group?(conn.assigns.current_scope.user.id, id) do
      conn
      |> redirect(to: ~p"/groups")
      |> halt()
    end

    received = Notes.get_received(conn.assigns.current_scope, id)
    received_map = Map.new(received, fn nicety -> {nicety.user_from_id, nicety} end)
    given = Notes.get_given(conn.assigns.current_scope, id)
    given_map = Map.new(given, fn nicety -> {nicety.user_to_id, nicety} end)
    members = Groups.get_all_members(id)

    other_users =
      Enum.filter(members, fn member -> member.id != conn.assigns.current_scope.user.id end)

    render(conn, :group,
      id: id,
      received_map: received_map,
      given_map: given_map,
      users: other_users
    )
  end

  def create_nicety(conn, %{"id" => id} = params) do
    nicety_params =
      Map.merge(params, %{"user_from_id" => conn.assigns.current_scope.user.id, "group_id" => id})

    case Notes.create_nicety(nicety_params) do
      {:ok, _nicety} -> redirect(conn, to: ~p"/groups/#{id}")
      {:error, _changeset} -> IO.puts("error")
    end
  end
end
