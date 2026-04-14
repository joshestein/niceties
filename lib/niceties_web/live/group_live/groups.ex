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
    <div class="pt-4 pb-16 font-light">
      <p class="text-xs tracking-[0.2em] uppercase text-warm/65">
        Your communities
      </p>

      <ul class="list-none p-0 m-0 mt-2">
        <li :for={group <- @groups} id={"group-#{group.id}"}>
          <.link
            navigate={~p"/groups/#{group.id}"}
            class="group flex items-baseline gap-3 py-4 border-b border-warm/15 no-underline transition-all duration-200 hover:pl-2 hover:text-warm text-warm/90 font-serif italic text-[1.6rem]"
          >
            <span class="not-italic font-sans text-xs tracking-[0.05em] text-warm/50 transition-colors duration-200 group-hover:text-warm/90">
              →
            </span>
            <span class="group-hover:underline">{group.name}</span>
          </.link>
        </li>
      </ul>
    </div>
    """
  end

  defp group_niceties(assigns) do
    ~H"""
    <div class="pt-4 pb-16 font-light">
      <.link
        navigate={~p"/groups/"}
        class="inline-flex items-center gap-2 font-sans text-xs tracking-[0.12em] uppercase text-warm/50 hover:text-warm/90 transition-colors duration-200 no-underline"
      >
        <span>←</span>
        <span>Groups</span>
      </.link>

      <h1 class="mt-8 leading-none tracking-[-0.01em] text-warm font-serif italic text-[clamp(2.5rem,7vw,4rem)]">
        {@group_name}
      </h1>

      <%!-- Tab navigation - uses CSS :target trick to toggle panels --%>
      <div class="mt-10 flex items-end gap-0 border-b border-warm/15">
        <a
          href="#given"
          class="nicety-tab-link font-sans px-1 pb-3 mr-6 text-xs tracking-[0.14em] uppercase transition-colors duration-200"
        >
          Given
        </a>
        <a
          href="#received"
          class="nicety-tab-link font-sans px-1 pb-3 text-xs tracking-[0.14em] uppercase transition-colors duration-200"
        >
          Received
        </a>
      </div>

      <%!-- Given panel --%>
      <ul id="given" class="list-none p-0 m-0 mt-8 space-y-4">
        <li :for={user <- @users} id={"user-#{user.id}"} class="flex gap-6 border-b border-warm/10 pb-4 divide-x divide-warm/15">
          <.user_avatar user={user} current_user_id={@current_user_id} />

          <.form
            for={@forms[user.id]}
            id={"form-user-#{user.id}"}
            phx-change="save_nicety"
            phx-value-user_to_id={user.id}
            class="flex-1"
          >
            <.input
              field={@forms[user.id][:body]}
              type="textarea"
              phx-debounce="blur"
              id={"nicety-body-#{user.id}"}
            />
            <.input
              type="checkbox"
              field={@forms[user.id][:anonymous]}
              label="Give anonymously?"
              id={"nicety-anonymous-#{user.id}"}
            />
          </.form>
        </li>
      </ul>

      <%!-- Received panel --%>
      <div id="received" class="mt-8">
        <%= if is_list(@received) do %>
          <%= if @received == [] do %>
            <p class="text-warm/40 font-serif italic text-[1.1rem]">
              Nothing here yet.
            </p>
          <% else %>
            <ul class="list-none p-0 m-0 space-y-8">
              <li :for={nicety <- @received} id={"received-#{nicety.id}"} class="flex gap-6 border-b border-warm/10 pb-8 divide-x divide-warm/15">
                <.user_avatar user={nicety.user_from} current_user_id={@current_user_id} />
                <p class="text-warm/80 leading-relaxed text-base font-light">
                  {nicety.body}
                </p>
              </li>
            </ul>
          <% end %>
        <% else %>
          <div class="py-8 border-b border-warm/10">
            <p class="text-warm/40 leading-relaxed font-serif italic text-[1.15rem]">
              {if is_nil(@received),
                do: "Niceties will be released soon.",
                else: "Releasing #{Calendar.strftime(@received, "%B %d, %Y")} at #{Calendar.strftime(@received, "%H:%M")} UTC"}
            </p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  attr :user, :map, required: true
  attr :current_user_id, :integer, required: true

  defp user_avatar(assigns) do
    ~H"""
    <div class="shrink-0 w-64 flex items-center gap-3 pr-6">
      <div class="size-16 rounded-full bg-warm/10 flex items-center justify-center shrink-0">
        <span class="text-warm/60 text-sm tracking-widest font-light">
          {initials(@user)}
        </span>
      </div>
      <div>
        <p class="font-serif italic text-warm text-[1.3rem] leading-tight">
          {@user && @user.name || "Anonymous"}
        </p>
        <span
          :if={@user && @user.id == @current_user_id}
          class="text-[0.65rem] tracking-widest uppercase text-warm/35"
        >
          you
        </span>
      </div>
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

  defp initials(nil), do: "?"

  defp initials(user) do
    user.name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
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
      group_name: group.name,
      users: users,
      forms: forms,
      received: received,
      current_user_id: current_scope.user.id
    }
  end
end
