defmodule NicetiesWeb.AvatarController do
  alias Niceties.Accounts
  use NicetiesWeb, :controller

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    if user.avatar do
      conn
      |> put_resp_content_type("image/webp")
      |> put_resp_header("cache-control", "private, max-age=86400")
      |> send_resp(200, user.avatar)
    else
      send_resp(conn, 404, "")
    end
  end
end
