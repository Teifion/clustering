defmodule Clustering.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ClusteringWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Clustering.PubSub},
      # Start the Endpoint (http/https)
      ClusteringWeb.Endpoint,
      {Clustering.NodeServer, name: Clustering.NodeServer},
      {Clustering.DbServer, name: Clustering.DbServer},
      # Start a worker by calling: Clustering.Worker.start_link(arg)
      # {Clustering.Worker, arg}

      {DynamicSupervisor, strategy: :one_for_one, name: Clustering.DynamicCacheSupervisor},

      concache_perm_sup(:app_cache),
    ]

    Logger.info("Starting app")
    Application.put_env(:elixir, :ansi_enabled, true)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Clustering.Supervisor]

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClusteringWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp concache_perm_sup(name) do
    Supervisor.child_spec(
      {
        ConCache,
        [
          name: name,
          ttl_check_interval: false
        ]
      },
      id: {ConCache, name}
    )
  end
end
