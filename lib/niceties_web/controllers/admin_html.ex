defmodule NicetiesWeb.AdminHTML do
  use NicetiesWeb, :html

  def groups(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.form for={@form} action={~p"/admin/groups"}>
        <.input label="Group name" field={@form[:name]} />
        <.input type="datetime-local" label="Releases at" field={@form[:releases_at]} />
        <.button>Create new group</.button>
      </.form>

      <hr />

      <ul>
        <li :for={group <- @groups} id={"group-#{group.id}"}>
          <.link href={~p"/admin/groups/#{group.id}"} class="hover:underline">
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
      <.link href={~p"/admin/groups"} class="hover:underline">← Back to groups</.link>

      <h1>Group: {@group.name}</h1>

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
        <:col :let={member} label="Status">{if is_nil(member.user.confirmed_at), do: "Invited", else: "Joined"}</:col>
      </.table>
    </Layouts.app>
    """
  end
end
