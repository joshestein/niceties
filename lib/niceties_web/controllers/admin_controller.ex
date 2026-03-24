defmodule NicetiesWeb.AdminController do
  use NicetiesWeb, :controller

  alias Niceties.Groups

  def groups(conn, _params) do
    groups = Groups.list_groups()
    render(conn, groups: groups)
  end

  def create_group(conn, _params) do

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
