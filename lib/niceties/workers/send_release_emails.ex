defmodule Niceties.Workers.SendReleaseEmails do
  alias Niceties.Accounts
  alias Niceties.Accounts.UserNotifier
  alias Niceties.Groups
  use Oban.Worker
  use NicetiesWeb, :verified_routes

  @impl true
  def perform(%Oban.Job{args: %{"group_id" => group_id, "user_id" => user_id}}) do
    UserNotifier.deliver_release_notification(
      Accounts.get_user!(user_id),
      NicetiesWeb.Endpoint.url() <> ~p"/groups/#{group_id}"
    )
  end

  # Fans out one job per member so a failed send retries only that member.
  def perform(%Oban.Job{args: %{"group_id" => group_id}}) do
    group_id
    |> Groups.get_all_memberships(true)
    |> Enum.map(&new(%{group_id: group_id, user_id: &1.user_id}))
    |> Oban.insert_all()

    :ok
  end
end
