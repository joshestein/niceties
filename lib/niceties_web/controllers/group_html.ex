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
        <.link href={~p"/groups/#{group.id}"} class="hover:underline">
          {group.name} - {group.id}
        </.link>
      </li>
    </Layouts.app>
    """
  end

  def group(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.link href={~p"/groups/"}>← Back to groups</.link>
      <li :for={user <- @users} id={"user-#{user.id}"}>
        {user.name}
        <.form :let={f} for={%{}} action={~p"/groups/#{@id}/niceties"}>
          <.input
            hidden
            field={f[:user_to_id]}
            value={Map.get(@given_map, user.id, %{user_to_id: user.id}).user_to_id}
          />
          <.input
            field={f[:body]}
            label="Nicety"
            value={Map.get(@given_map, user.id, %{body: ""}).body}
          />
          <div class="flex flex-row justify-between">
            <.input
              type="checkbox"
              field={f[:anonymous]}
              label="Give anonymously?"
              value={Map.get(@given_map, user.id, %{anonymous: false}).anonymous}
            />

            <.button type="submit">Save</.button>
          </div>
        </.form>
      </li>
    </Layouts.app>
    """
  end
end
