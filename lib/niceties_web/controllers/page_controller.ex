defmodule NicetiesWeb.PageController do
  use NicetiesWeb, :controller

  alias Niceties.Groups

  def home(conn, _params) do
    groups =
      case conn.assigns[:current_scope] do
        nil -> []
        scope -> Groups.list_groups_for_user(scope)
      end

    render(conn, :home, groups: groups)
  end
end
