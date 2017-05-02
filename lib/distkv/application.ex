defmodule Distkv.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, args) do
    # Read provided :node_addr from config.exs
    node_addr = Application.get_env(:distkv, :node_addr)

    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts DkvServer (GenServer) with node_addr as argument
      worker(Distkv.DkvServer, [node_addr]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Distkv.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
