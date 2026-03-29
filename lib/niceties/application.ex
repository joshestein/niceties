defmodule Niceties.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NicetiesWeb.Telemetry,
      Niceties.Repo,
      {Oban, Application.fetch_env!(:niceties, Oban)},
      {DNSCluster, query: Application.get_env(:niceties, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Niceties.PubSub},
      # Start a worker by calling: Niceties.Worker.start_link(arg)
      # {Niceties.Worker, arg},
      # Start to serve requests, typically the last entry
      NicetiesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Niceties.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NicetiesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
