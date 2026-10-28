defmodule Niceties.Workers.SendReleaseEmailsTest do
  use Niceties.DataCase
  use Oban.Testing, repo: Niceties.Repo

  import Niceties.AccountsFixtures
  import Niceties.GroupsFixtures

  alias Niceties.Workers.SendReleaseEmails

  test "enqueues one job per confirmed member" do
    group = group_fixture()
    member = user_fixture()
    unconfirmed = unconfirmed_user_fixture()
    membership_fixture(%{group_id: group.id, user_id: member.id, role: "participant"})
    membership_fixture(%{group_id: group.id, user_id: unconfirmed.id, role: "participant"})

    assert :ok = perform_job(SendReleaseEmails, %{group_id: group.id})

    assert_enqueued(worker: SendReleaseEmails, args: %{group_id: group.id, user_id: member.id})
    refute_enqueued(worker: SendReleaseEmails, args: %{user_id: unconfirmed.id})
  end

  test "sends the release email to one member" do
    group = group_fixture()
    user = user_fixture()

    assert {:ok, _} = perform_job(SendReleaseEmails, %{group_id: group.id, user_id: user.id})

    # Fixtures also send login emails, so match on subject instead of the next email.
    assert_received {:email, %{subject: "Your group's niceties have been released!"} = email}
    assert email.to == [{"", user.email}]
  end
end
