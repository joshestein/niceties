defmodule NicetiesWeb.AvatarController do
  alias Niceties.Groups
  alias Niceties.Accounts
  use NicetiesWeb, :controller

  def show(conn, %{"id" => id}) do
    viewer = conn.assigns.current_scope.user
    user = Accounts.get_user!(id)

    if user.avatar && Groups.shares_group?(viewer.id, user.id) do
      conn
      |> put_resp_content_type("image/webp")
      |> put_resp_header("cache-control", "private, max-age=86400")
      |> send_resp(200, user.avatar)
    else
      send_resp(conn, 404, "")
    end
  end
end
