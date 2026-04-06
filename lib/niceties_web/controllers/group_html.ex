defmodule NicetiesWeb.GroupHTML do
  @moduledoc """
  This module contains pages rendered by GroupController.

  See the `group_html` directory for all templates available.
  """
  use NicetiesWeb, :html

  # embed_templates "group_html/*"

  def index(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <ul>
        <li :for={group <- @groups} id={"group-#{group.id}"}>
          <.link href={~p"/groups/#{group.id}"} class="hover:underline">
            {group.name} - {group.id}
          </.link>
        </li>
      </ul>
    </Layouts.app>
    """
  end
end
