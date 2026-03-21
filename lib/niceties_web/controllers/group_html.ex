defmodule NicetiesWeb.GroupHTML do
  @moduledoc """
  This module contains pages rendered by GroupController.

  See the `group_html` directory for all templates available.
  """
  use NicetiesWeb, :html

  # embed_templates "group_html/*"

  def index(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <li :for={group <- @groups} id={"group-#{group.id}"}>
        {group.name} - {group.id}
      </li>
    </Layouts.app>
    """
  end

  def group(assigns) do
    ~H"""
    group {@id}
    """
  end
end
