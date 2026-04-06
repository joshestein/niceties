defmodule NicetiesWeb.GroupController do
  use NicetiesWeb, :controller
  alias Niceties.Groups

  def index(conn, _params) do
    groups = Groups.list_groups_for_user(conn.assigns.current_scope)
    render(conn, :index, groups: groups)
  end
end
