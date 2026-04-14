defmodule NicetiesWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use NicetiesWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="border-warm/10 border-b px-4 sm:px-6 lg:px-8">
      <div class="mx-auto flex h-14 max-w-2xl items-center justify-between">
        <.link
          href={~p"/"}
          class="text-warm/90 font-serif text-2xl font-light italic leading-none transition-colors duration-150 hover:text-warm"
        >
          Niceties
        </.link>
        <%= if @current_scope do %>
          <nav class="text-[0.68rem] tracking-[0.08em] flex items-center gap-3 uppercase sm:tracking-[0.14em] sm:gap-5">
            <span class="text-warm/40 hidden sm:inline">
              {@current_scope.user.name || @current_scope.user.email}
            </span>
            <.link
              href={~p"/groups"}
              class="text-warm/90 transition-colors duration-150 hover:text-warm"
            >
              Groups
            </.link>
            <.link
              href={~p"/users/settings"}
              class="text-warm/90 transition-colors duration-150 hover:text-warm"
            >
              Settings
            </.link>
            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="text-warm/90 transition-colors duration-150 hover:text-warm"
            >
              Log out
            </.link>
          </nav>
        <% else %>
          <nav>
            <.link
              href={~p"/users/log-in"}
              class="text-[0.68rem] tracking-[0.14em] text-warm/85 uppercase transition-colors duration-150 hover:text-warm"
            >
              Log in
            </.link>
          </nav>
        <% end %>
      </div>
    </header>

    <main class="px-4 pt-10 pb-16 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="size-3 ml-1 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="size-3 ml-1 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
