defmodule NicetiesWeb.AdminHTML do
  use NicetiesWeb, :html

  def groups(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <ul>
        <li :for={group <- @groups} id={"group-#{group.id}"}>
          <.link href={~p"/admin/groups/#{group.id}"} class="hover:underline">
            {group.name} - {group.id}
          </.link>
        </li>
      </ul>
    </Layouts.app>
    """
  end

  def group(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.link href={~p"/admin/groups"} class="hover:underline">← Back to groups</.link>

      <h1>Group: {@group.name}</h1>

      <.table id="members" rows={@members}>
        <:col :let={member} label="Name">{member.user.name}</:col>
        <:col :let={member} label="Email">{member.user.email}</:col>
        <:col :let={member} label="Role">{member.role}</:col>
      </.table>
    </Layouts.app>
    """
  end
end
