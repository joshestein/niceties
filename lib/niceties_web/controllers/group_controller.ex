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

  def create_nicety(conn, %{"id" => group_id, "user_id" => user_to_id, "nicety" => nicety_params}) do
    nicety_params =
      Map.merge(nicety_params, %{
        "user_from_id" => conn.assigns.current_scope.user.id,
        "user_to_id" => user_to_id,
        "group_id" => group_id
      })

    case Notes.upsert_nicety(nicety_params) do
      {:ok, _nicety} ->
        redirect(conn, to: ~p"/groups/#{group_id}")

      {:error, changeset} ->
        assigns = group_assigns(conn, group_id)
        forms = Map.put(assigns.forms, String.to_integer(user_to_id), to_form(changeset))

        conn
        |> put_flash(:error, "Failed to save nicety")
        |> render(:group, Map.put(assigns, :forms, forms))
    end
  end

  defp group_assigns(conn, id) do
    given = Notes.get_given(conn.assigns.current_scope, id)
    given_map = Map.new(given, fn nicety -> {nicety.user_to_id, nicety} end)
    group = Groups.get_group!(id)

    received =
      cond do
        is_nil(group.releases_at) ->
          nil

        DateTime.before?(group.releases_at, DateTime.utc_now()) ->
          Notes.get_received(conn.assigns.current_scope, id)

        true ->
          group.releases_at
      end

    members = Groups.get_all_memberships(group)

    users = Enum.map(members, fn member -> member.user end)

    forms =
      Map.new(users, fn user ->
        nicety = Map.get(given_map, user.id, %Nicety{})
        {user.id, to_form(Notes.change_nicety(nicety))}
      end)

    %{
      id: id,
      users: users,
      forms: forms,
      received: received,
      current_user_id: conn.assigns.current_scope.user.id
    }
  end
end
