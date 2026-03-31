defmodule Niceties.Workers.SendReleaseEmails do
  alias Niceties.Accounts.UserNotifier
  alias Niceties.Groups
  use Oban.Worker
  use NicetiesWeb, :verified_routes

  @impl true
  def perform(%Oban.Job{args: %{"group_id" => group_id}}) do
    memberships = Groups.get_all_memberships(group_id, true)

    Enum.reduce_while(memberships, :ok, fn membership, _acc ->
      case UserNotifier.deliver_release_notification(
             membership.user,
             NicetiesWeb.Endpoint.url() <> ~p"/groups/#{group_id}"
           ) do
        {:ok, _} -> {:cont, :ok}
        {:error, _} -> {:halt, {:error, "Failed to send email to group #{group_id}"}}
      end
    end)
  end
end
