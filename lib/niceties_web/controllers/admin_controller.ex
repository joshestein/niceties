defmodule NicetiesWeb.AdminController do
  use NicetiesWeb, :controller
  import Phoenix.Component, only: [to_form: 1]

  alias Niceties.Groups
  alias Niceties.Groups.Group

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
    render(conn, members: members, group: group)
  end

  def release(conn, _params) do

  end

  def add_member(conn, _params) do

  end
end
