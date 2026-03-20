defmodule NicetiesWeb.GroupController do
  use NicetiesWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def group(conn, %{"id" => id}) do
    render(conn, :group, id: id)
  end

  def nicety(conn, _params) do
  end
end
