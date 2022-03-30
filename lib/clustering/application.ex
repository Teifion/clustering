defmodule Clustering.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    topologies = [
      cbox: [
        strategy: Cluster.Strategy.Epmd,
        # config: [hosts: ~w(clustering@cbox1 clustering@cbox2 clustering@cbox3 clustering@cbox4)a],
        config: [hosts: [:nonode@nohost]],
      ]
    ]

    children = [
      # Start the Telemetry supervisor
      ClusteringWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Clustering.PubSub},
      # Start the Endpoint (http/https)
      ClusteringWeb.Endpoint,
      Clustering.DbServer,

      # Swarm
      # Swarm.whereis_or_register_name(Clustering.ValueServer, Clustering.ValueServer, :start_link, [])
      {Cluster.Supervisor, [topologies, [name: Clustering.ValueSupervisor]]},

      # Horde
      # Note the name of Cluster.Supervisor is from libcluster, not the Clustering app
      # {Cluster.Supervisor, [topologies, [name: Clustering.LibClusterSupervisor]]},
      # {Horde.Registry, [name: Clustering.ValueRegistry, keys: :unique]},
      # {Horde.DynamicSupervisor, [name: Clustering.ValueSupervisor, strategy: :one_for_one]},

      # {DynamicSupervisor, strategy: :one_for_one, name: Clustering.ValueSupervisor},
      # {Clustering.CoordinatorServer, name: Clustering.CoordinatorServer},

      concache_perm_sup(:node_cache),
      concache_perm_sup(:shared_cache),
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
