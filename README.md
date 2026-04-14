# Niceties

Inspired by the Recurse Centre's niceties system. Built as a learning project for Phoenix/Elixir.

Niceties are short pieces of positive feedback that group members write to each other. They're kept private until the group admin releases them, either on a scheduled date or manually.

## Stack

- **Elixir / Phoenix 1.8** with LiveView
- **PostgreSQL** via Ecto
- **Oban** for background jobs
- **Swoosh** for email (magic link auth)
- **Tailwind CSS** + esbuild

## Data model

- **User** - email, name, email confirmation
- **Group** - name, release date, released flag
- **Membership** - joins users to groups with a role (`admin`, `staff`, `participant`)
- **Nicety** - body text, sender (`user_from`), recipient (`user_to`), group, anonymous flag

## User flow

1. Admin creates a group and sets an optional release date
2. Admin invites members by email (users are created on first invite)
3. Members log in via magic link (no passwords)
4. Members write niceties to each other; anonymous submissions hide the sender
5. On release, members can read the niceties they received

## Auth

Session-based magic link auth - no passwords. Tokens are valid for 14 days with a 7-day reissue window for active
sessions. Email confirmation is required before accessing group features.
