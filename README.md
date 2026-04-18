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

## Deployment

These instructions assume you are building and running on the same VPS.

### Prerequisites

- Elixir and Erlang installed (see `.tool-versions` for versions)
- PostgreSQL running
- Caddy installed and running as a reverse proxy (handles TLS automatically)

### Caddy

Add to your `Caddyfile`:

```caddy
niceties.example.com {
    reverse_proxy localhost:4000
}
```

Caddy will handle TLS automatically via Let's Encrypt.

### Environment variables

Set these before running any production commands, e.g. in `/etc/niceties.env` or your systemd `EnvironmentFile`:

```ini
SECRET_KEY_BASE=     # generate with: mix phx.gen.secret
DATABASE_URL=        # e.g. ecto://user:pass@localhost/niceties_prod
PHX_HOST=            # your domain, e.g. niceties.example.com
PORT=4000
MAILGUN_API_KEY=
MAILGUN_DOMAIN=
```

### First deploy

```sh
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix ecto.migrate
MIX_ENV=prod mix phx.server
```

### Subsequent deploys

```sh
git pull
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix ecto.migrate
systemctl restart niceties
```

### systemd

Create `/etc/systemd/system/niceties.service`:

```ini
[Unit]
Description=Niceties
After=network.target postgresql.service

[Service]
User=niceties
WorkingDirectory=/home/niceties/app
EnvironmentFile=/etc/niceties.env
ExecStart=/usr/bin/env MIX_ENV=prod mix phx.server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Then:

```sh
systemctl daemon-reload
systemctl enable niceties
systemctl start niceties
```

---
