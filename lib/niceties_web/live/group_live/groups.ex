defmodule NicetiesWeb.GroupLive.Groups do
  use NicetiesWeb, :live_view
  alias Niceties.Groups
  alias Niceties.Notes
  alias Niceties.Notes.Nicety

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <%= if @live_action == :index do %>
        <.groups_index {assigns} />
      <% else %>
        <.group_niceties {assigns} />
      <% end %>
    </Layouts.app>
    """
  end

  defp groups_index(assigns) do
    ~H"""
    <ul id="groups">
      <li :for={group <- @groups} id={"group-#{group.id}"}>
        <.link navigate={~p"/groups/#{group.id}"} class="hover:underline">
          {group.name} - {group.id}
        </.link>
      </li>
    </ul>
    """
  end

  defp group_niceties(assigns) do
    ~H"""
    <.link navigate={~p"/groups/"}>← Back to groups</.link>

    <div class="mt-4">
      <a href="#given" class="text-xl">Given niceties</a>
      <span class="text-xl"> | </span>
      <a href="#received" class="text-xl">Received niceties</a>
    </div>

    <ul id="given">
      <li :for={user <- @users} id={"user-#{user.id}"} class="mt-4">
        {user.name}
        <span :if={user.id == @current_user_id}> ⋅ That's you!</span>
        <.form
          for={@forms[user.id]}
          id={"form-user-#{user.id}"}
          phx-change="save_nicety"
          phx-value-user_to_id={user.id}
        >
          <.input field={@forms[user.id][:body]} label="Nicety" phx-debounce="blur" />
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
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    groups = Groups.list_groups_for_user(socket.assigns.current_scope)
    assign(socket, :groups, groups)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    user = socket.assigns.current_scope.user

    if Groups.member_of_group?(user.id, id) do
      assign(socket, group_assigns(socket.assigns.current_scope, id))
    else
      redirect(socket, to: ~p"/groups")
    end
  end

  @impl true
  def handle_event("save_nicety", %{"nicety" => params, "user_to_id" => user_to_id}, socket) do
    nicety_params =
      Map.merge(params, %{
        "user_from_id" => socket.assigns.current_scope.user.id,
        "user_to_id" => user_to_id,
        "group_id" => socket.assigns.id
      })

    case Notes.upsert_nicety(nicety_params) do
      {:ok, nicety} ->
        forms =
          Map.put(
            socket.assigns.forms,
            String.to_integer(user_to_id),
            to_form(Notes.change_nicety(nicety))
          )

        {:noreply, assign(socket, :forms, forms)}

      {:error, changeset} ->
        forms = Map.put(socket.assigns.forms, String.to_integer(user_to_id), to_form(changeset))

        {:noreply, assign(socket, :forms, forms)}
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
