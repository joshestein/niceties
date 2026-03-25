defmodule NicetiesWeb.AdminController do
  use NicetiesWeb, :controller
  import Phoenix.Component, only: [to_form: 1]

  alias Niceties.Accounts
  alias Niceties.Groups
  alias Niceties.Groups.Group
  alias Niceties.Groups.Membership

  def groups(conn, _params) do
    groups = Groups.list_groups()
    render(conn, groups: groups, form: to_form(Groups.change_group(%Group{})))
  end

  def create_group(conn, %{"group" => %{"name" => name, "releases_at" => releases_at}}) do
    group_params = %{"name" => name, "releases_at" => releases_at}

    case Groups.create_group(group_params) do
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
    members = Groups.get_all_memberships(id)

    render(conn,
      members: members,
      group: group,
      form: to_form(Groups.change_membership(%Membership{}))
    )
  end

  def release(_conn, _params) do
  end

  def create_member(conn, %{
        "id" => id,
        "membership" => %{"name" => name, "email" => email, "role" => role}
      }) do

    case Groups.create_member(%{name: name, email: email, role: role, group_id: id}) do
      {:ok, _membership} ->
        # TODO: trigger registration flow
        conn |> redirect(to: ~p"/admin/groups/#{id}")

      {:error, _step, changeset, _changes} ->
        group = Groups.get_group!(id)
        members = Groups.get_all_memberships(id)
        conn
        |> put_flash(:error, "Failed to create member")
        |> render(:group, id: id, group: group, members: members, form: to_form(changeset))
    end

  end
end
