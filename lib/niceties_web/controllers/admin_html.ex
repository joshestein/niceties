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
end
