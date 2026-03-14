defmodule NicetiesWeb.PageController do
  use NicetiesWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
