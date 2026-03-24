defmodule NicetiesWeb.AdminHTML do
  use NicetiesWeb, :html

  def groups(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <li :for={group <- @groups} id={"group-#{group.id}"}>
        <.link href={~p"/admin/groups/#{group.id}"} class="hover:underline">
          {group.name} - {group.id}
        </.link>
      </li>
    </Layouts.app>
    """
  end

  def group(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.link href={~p"/admin/groups"} class="hover:underline">← Back to all groups</.link>

      <h1>Group: {@group.name}</h1>

      <.table id="users" rows={@users}>
        <:col :let={user} label="Name">{user.name}</:col>
        <:col :let={user} label="Email">{user.email}</:col>
      </.table>
    </Layouts.app>
    """
  end
end
