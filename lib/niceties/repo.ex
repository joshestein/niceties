defmodule Niceties.Repo do
  use Ecto.Repo,
    otp_app: :niceties,
    adapter: Ecto.Adapters.Postgres
end
