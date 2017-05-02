# Distkv

## Description

I made this simple project, based on [https://github.com/mmmries/dkv](https://github.com/mmmries/dkv) repo, that uses [https://github.com/lindenbaum/lbm_kv](https://github.com/lindenbaum/lbm_kv) project to provides distributed key-value in-memory db for elixir project.

Based on [https://github.com/mmmries/dkv](https://github.com/mmmries/dkv) project, you are **required to LINK ALL NODES** using **sys.config** file. Consequently, you must know your nodes and register it in **sys.config** file before you can start your app in many nodes.

This approach doesn't really suit my requirement, as I want to be able to start my app in 1 node then scalling horizontally as needed. So I want to be able to provide **NODE NAME** everytime I want to start my app in 2nd, 3rd node and so on.

So by following a simple **TRICK** in [https://medium.com/@jmerriweather/elixir-phoenix-amnesia-multi-node-451e8565da1d](https://medium.com/@jmerriweather/elixir-phoenix-amnesia-multi-node-451e8565da1d) project, I code my **/config/config.exs** like below:

```
use Mix.Config

# Takes JOIN_TO env variable provided by deployer (if any) on starting this app 
config :distkv, node_addr: System.get_env("JOIN_TO")
```

Then in **/lib/application.ex**, my start block codes is like below:

```
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
  ```

How **Distkv.DkvServer (/lib/dkv_server.ex)** magically initiates **node connections** then starts Mnesia replications with previously established Mnesia can be view in [dkv_server.ex](https://github.com/bromoapp/distkv/blob/master/lib/distkv/dkv_server.ex)

Part of my code in **dkv_server.ex** came from this guy: [@mmmries](https://github.com/mmmries) sample in [here](https://github.com/lindenbaum/lbm_kv/issues/1), thank him for that :)

## How to test this app

**P.S. I'm using Windows OS here**

# Start 1st node
```
$ iex --name node_1@YOUR_IP --cookie freak -S mix run
iex(node_1@YOUR_IP)1> alias Distkv.DkvServer
iex(node_1@YOUR_IP)2> DkvServer.insert(:one, "Hello World")
[]
iex(node_1@YOUR_IP)3> DkvServer.select_all
[one: "Hello World"]
```

# Start 2nd node
```
$ set JOIN_TO=node_1@YOUR_IP
$ iex --name node_2@YOUR_IP --cookie freak -S mix run
iex(node_2@YOUR_IP)1> alias Distkv.DkvServer
iex(node_2@YOUR_IP)2> DkvServer.select_all
[one: "Hello World"]
```

That's it guys... good luck with your project, I hope this would help you somehow :D

