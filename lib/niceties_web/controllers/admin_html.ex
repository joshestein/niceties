defmodule NicetiesWeb.AdminHTML do
  use NicetiesWeb, :html

  alias Niceties.Groups

  def groups(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.form for={@form} action={~p"/admin/groups"}>
        <.input label="Group name" field={@form[:name]} />
        <.input type="datetime-local" label="Releases at" field={@form[:releases_at]} />
        <.button>Create new group</.button>
      </.form>

      <hr />

      <ul>
        <li
          :for={group <- @groups}
          id={"group-#{group.id}"}
          class="flex items-center justify-between rounded-lg border p-4"
        >
          <.link href={~p"/admin/groups/#{group.id}"} class="font-medium hover:underline">
            {group.name}
          </.link>
          <div class="flex items-center gap-4">
            <.release_status group={group} />
            <.release_form
              :if={!group.released}
              action={~p"/admin/groups/#{group.id}/release"}
              return_to={~p"/admin/groups"}
            />
          </div>
        </li>
      </ul>
    </Layouts.app>
    """
  end

  def group(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.link href={~p"/admin/groups"} class="hover:underline">← Back to groups</.link>

      <div class="mt-4 flex flex-col justify-between gap-1">
        <h1 class="text-xl font-semibold">Group: {@group.name}</h1>
        <%= if @group.released do %>
          <span class="text-success text-sm">
            Released<%= if @group.releases_at do %>
              {Calendar.strftime(@group.releases_at, "%b %d, %Y")}
            <% end %>
          </span>
        <% else %>
          <div class="mt-2 flex items-end gap-2">
            <.form
              for={to_form(Groups.change_group(@group))}
              action={~p"/admin/groups/#{@group.id}"}
              method="put"
              class="flex items-end gap-2"
            >
              <.input
                type="datetime-local"
                label="Release date"
                field={to_form(Groups.change_group(@group))[:releases_at]}
              />
              <div class="fieldset mb-2">
                <span class="label invisible mb-1">x</span>
                <.button class="btn btn-soft btn-primary">Update</.button>
              </div>
            </.form>
            <.form for={%{}} action={~p"/admin/groups/#{@group.id}/release"} class="fieldset mb-2">
              <span class="label invisible mb-1">x</span>
              <input type="hidden" name="return_to" value={~p"/admin/groups/#{@group.id}"} />
              <.button class="btn btn-primary">Release now</.button>
            </.form>
          </div>
        <% end %>
      </div>

      <.form for={@form} action={~p"/admin/groups/#{@group.id}/members"}>
        <.input label="Name" field={@form[:name]} />
        <.input label="Email" field={@form[:email]} />
        <.input
          label="Role"
          type="select"
          options={[Participant: "participant", Staff: "staff"]}
          field={@form[:role]}
        />
        <.button variant="primary">Invite user</.button>
      </.form>

      <.table id="members" rows={@members}>
        <:col :let={member} label="Name">{member.user.name}</:col>
        <:col :let={member} label="Email">{member.user.email}</:col>
        <:col :let={member} label="Role">{member.role}</:col>
        <:col :let={member} label="Status">
          {if is_nil(member.user.confirmed_at), do: "Invited", else: "Joined"}
        </:col>
      </.table>
    </Layouts.app>
    """
  end

  defp release_form(assigns) do
    ~H"""
    <.form for={%{}} action={@action}>
      <input type="hidden" name="return_to" value={@return_to} />
      <.button>Release now</.button>
    </.form>
    """
  end

  defp release_status(assigns) do
    ~H"""
    <%= cond do %>
      <% @group.released -> %>
        <span class="text-success text-sm">
          Released
          <%= if @group.releases_at do %>
            {Calendar.strftime(@group.releases_at, "%b %d, %Y")}
          <% end %>
        </span>
      <% @group.releases_at -> %>
        <span class="text-warning text-sm">
          Scheduled for {Calendar.strftime(@group.releases_at, "%b %d, %Y")}
        </span>
      <% true -> %>
        <span class="text-base-content/50 text-sm">Not yet scheduled</span>
    <% end %>
    """
  end
end
