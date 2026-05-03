defmodule NicetiesWeb.AdminController do
  use NicetiesWeb, :controller
  import Phoenix.Component, only: [to_form: 1]

  alias Niceties.Accounts
  alias Niceties.Groups
  alias Niceties.Groups.Group
  alias Niceties.Groups.Membership

  def groups(conn, _params) do
    groups = Groups.list_admin_groups_for_user(conn.assigns.current_scope)
    render(conn, groups: groups, form: to_form(Groups.change_group(%Group{})))
  end

  def create_group(conn, %{"group" => %{"name" => name, "releases_at" => releases_at}}) do
    group_params = %{"name" => name, "releases_at" => releases_at}
    user_id = conn.assigns.current_scope.user.id

    case Groups.create_group(group_params, user_id) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Successfully created group")
        |> redirect(to: ~p"/admin/groups/#{group.id}")

      {:error, changeset} ->
        groups = Groups.list_groups()

        conn
        |> put_flash(:error, "Failed to create group")
        |> render(:groups, groups: groups, form: to_form(changeset))
    end
  end

  def group(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    members = Groups.get_all_memberships(group)

    render(conn,
      members: members,
      group: group,
      form: to_form(Groups.change_membership(%Membership{}))
    )
  end

  def update_group(conn, %{"id" => id, "group" => group_params}) do
    group = Groups.get_group!(id)

    case Groups.update_group(group, group_params) do
      {:ok, _group} ->
        conn |> put_flash(:info, "Group updated") |> redirect(to: ~p"/admin/groups/#{id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to update group")
        |> redirect(to: ~p"/admin/groups/#{id}")
    end
  end

  def release(conn, %{"id" => id, "return_to" => return_to}) do
    group = Groups.get_group!(id)

    case Groups.update_group(group, %{released: true}) do
      {:ok, _group} ->
        conn |> put_flash(:info, "Niceties released!") |> redirect(to: safe_return_to(return_to))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to release niceties")
        |> redirect(to: safe_return_to(return_to))
    end
  end

  def create_member(conn, %{
        "id" => id,
        "membership" => %{"name" => name, "email" => email, "role" => role}
      }) do
    group = Groups.get_group!(id)

    case Groups.create_member(%{name: name, email: email, role: role, group_id: id}) do
      {:ok, %{resolved_user: user, membership: _membership}} ->
        Accounts.deliver_login_instructions(
          user,
          &url(~p"/users/log-in/#{&1}"),
          group.name
        )

        conn |> redirect(to: ~p"/admin/groups/#{id}")

      {:error, _step, changeset, _changes} ->
        members = Groups.get_all_memberships(group)

        conn
        |> put_flash(:error, "Failed to create member")
        |> render(:group, id: id, group: group, members: members, form: to_form(changeset))
    end
  end

  defp safe_return_to(path)
       when is_binary(path) and
              binary_part(path, 0, 1) ==
                "/",
       do: path

  defp safe_return_to(_), do: ~p"/admin/groups"
end
