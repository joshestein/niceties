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

  def group(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.link href={~p"/groups/"}>← Back to groups</.link>

      <h1 class="text-xl mt-4">Given niceties</h1>
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

      <h1 class="text-xl mt-4">Received niceties</h1>
      <%= if is_list(@received) do %>
        <ul>
          <li :for={nicety <- @received} id="received-#{nicety.id}">
            <%= if nicety.user_from do %>
              <span class="font-semibold">{nicety.user_from.name}</span>
            <% else %>
              <span class="font-semibold">Anonymous</span>
            <% end %>
            {nicety.body}
          </li>
        </ul>
      <% else %>
        {if is_nil(@received),
          do: "Niceties will be released soon",
          else:
            "Niceties will be released on #{Calendar.strftime(@received, "%B %d, %Y at %H:%M UTC")}"}
      <% end %>
    </Layouts.app>
    """
  end
end
