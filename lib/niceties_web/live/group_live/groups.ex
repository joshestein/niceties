defmodule NicetiesWeb.GroupLive.Groups do
  use NicetiesWeb, :live_view
  alias Niceties.Groups
  alias Niceties.Notes
  alias Niceties.Notes.Nicety

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.link href={~p"/groups/"}>← Back to groups</.link>

      <div class="mt-4">
        <a href="#given" class="text-xl">Given niceties</a>
        <span class="text-xl"> | </span>
        <a href="#received" class="text-xl">Received niceties</a>
      </div>

      <ul id="given">
        <li :for={user <- @users} id={"user-#{user.id}"} class="mt-4">
          {user.name}
          <span :if={user.id == @current_user_id}> ⋅ That's you!</span>
          <.form for={@forms[user.id]} id={"form-user-#{user.id}"} phx-change="save_nicety" phx-value-user_to_id={user.id}>
            <.input field={@forms[user.id][:body]} label="Nicety" phx-debounce="blur"/>
            <div class="flex flex-row justify-between">
              <.input
                type="checkbox"
                field={@forms[user.id][:anonymous]}
                label="Give anonymously?"
              />
            </div>
          </.form>
        </li>
      </ul>

      <div id="received">
        <%= if is_list(@received) do %>
          <ul>
            <li :for={nicety <- @received} id={"received-#{nicety.id}"}>
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
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_scope.user
    if Groups.member_of_group?(user.id, id) do
      socket = assign(socket, group_assigns(socket.assigns.current_scope, id))
      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/groups")}
    end
  end

  @impl true
  def handle_event("save_nicety", %{"nicety" => params, "user_to_id" => user_to_id}, socket) do
    nicety_params =
      Map.merge(params, %{
        "user_from_id" => socket.assigns.current_scope.user.id,
        "user_to_id" => user_to_id,
        "group_id" => socket.assigns.id,
      })

    case Notes.upsert_nicety(nicety_params) do
      {:ok, nicety} ->
        new_form = to_form(Notes.change_nicety(nicety))
        forms = Map.put(socket.assigns.forms, String.to_integer(user_to_id), new_form)
        {:noreply, assign(socket, :forms, forms)}

      {:error, changeset} ->
        assigns = group_assigns(socket.assigns.current_scope, socket.assigns.id)
        forms = Map.put(assigns.forms, String.to_integer(user_to_id), to_form(changeset))

        {:noreply, assign(socket, Map.put(assigns, :forms, forms))}
    end
  end

  defp group_assigns(current_scope, id) do
    given = Notes.get_given(current_scope, id)
    given_map = Map.new(given, fn nicety -> {nicety.user_to_id, nicety} end)
    group = Groups.get_group!(id)

    received =
      if group.released do
        Notes.get_received(current_scope, id)
      else
        group.releases_at
      end

    members = Groups.get_all_memberships(group)

    users = Enum.map(members, fn member -> member.user end)

    forms =
      Map.new(users, fn user ->
        nicety = Map.get(given_map, user.id, %Nicety{})
        {user.id, to_form(Notes.change_nicety(nicety))}
      end)

    %{
      id: id,
      users: users,
      forms: forms,
      received: received,
      current_user_id: current_scope.user.id
    }
  end
end
