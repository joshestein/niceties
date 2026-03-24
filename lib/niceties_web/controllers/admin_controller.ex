defmodule NicetiesWeb.AdminController do
  use NicetiesWeb, :controller

  alias Niceties.Groups

  def groups(conn, _params) do
    groups = Groups.list_groups()
    render(conn, groups: groups)
  end

  def create_group(conn, %{"name" => _name, "releases_at" => _releases_at} = params) do
    case Groups.create_group(params) do
      {:ok, group} ->
        conn |> put_flash(:info, "Successfully created group") |> redirect(to: ~p"/admin/groups/#{group.id}")
      _ ->
        conn |> put_flash(:error, "Failed to create group") |> redirect(to: ~p"/admin/groups")
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
