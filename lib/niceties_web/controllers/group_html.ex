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
      <ul>
        <li :for={user <- @users} id={"user-#{user.id}"}>
          {user.name}
          <.form for={@forms[user.id]} action={~p"/groups/#{@id}/niceties/#{user.id}"}>
            <.input field={@forms[user.id][:body]} label="Nicety" />
            <div class="flex flex-row justify-between">
              <.input
                type="checkbox"
                field={@forms[user.id][:anonymous]}
                label="Give anonymously?"
              />
              <.button type="submit">Save</.button>
            </div>
          </.form>
        </li>
      </ul>
    </Layouts.app>
    """
  end
end
