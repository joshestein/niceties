# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Niceties.Repo.insert!(%Niceties.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Niceties.Repo.delete_all(Niceties.Notes.Nicety)
Niceties.Repo.delete_all(Niceties.Groups.Membership)
Niceties.Repo.delete_all(Niceties.Groups.Group)
Niceties.Repo.delete_all(Niceties.Accounts.User)

{:ok, user} = Niceties.Accounts.create_user(%{email: "mail@gmail.com", name: "John Doe"})

{:ok, group} =
  Niceties.Groups.create_group(%{name: "my_group", releases_at: ~U[2026-06-01 18:00:00Z]})

Niceties.Groups.create_membership(%{role: "admin", group_id: group.id, user_id: user.id})

{:ok, fellow} = Niceties.Accounts.create_user(%{email: "fellow@gmail.com", name: "Fellow 1"})
{:ok, fellow_2} = Niceties.Accounts.create_user(%{email: "fellow2@gmail.com", name: "Fellow 2"})

Niceties.Groups.create_membership(%{role: "participant", group_id: group.id, user_id: fellow.id})
Niceties.Groups.create_membership(%{role: "participant", group_id: group.id, user_id: fellow_2.id})

Niceties.Notes.create_nicety(%{body: "you are so nice", group_id: group.id, user_from_id: user.id, user_to_id: fellow.id})
Niceties.Notes.create_nicety(%{body: "awesome sauce", group_id: group.id, user_from_id: user.id, user_to_id: fellow_2.id})
