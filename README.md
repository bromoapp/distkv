# Distkv

## Description

I made this simple project, based on [https://github.com/mmmries/dkv](https://github.com/mmmries/dkv) repo, that uses [https://github.com/lindenbaum/lbm_kv](https://github.com/lindenbaum/lbm_kv) project to provides distributed key-value in-memory db for elixir project.

Based on [https://github.com/mmmries/dkv](https://github.com/mmmries/dkv) project, you are **required to LINK ALL NODES** using **sys.config** file. You must know your nodes and register it in **sys.config** file before you can start your app in many nodes.

This approach doesn't really suit my requirement, as I want to be able to start my app in 1 node then scalling horizontally as needed. So I want to be able to provide **NODE NAME** everytime I want to start my app in 2nd, 3rd node and so on.

So by following a simple **TRICK** in [https://medium.com/@jmerriweather/elixir-phoenix-amnesia-multi-node-451e8565da1d](https://medium.com/@jmerriweather/elixir-phoenix-amnesia-multi-node-451e8565da1d), I code my **/config/config.exs** like below:

```
use Mix.Config
config :distkv, node_addr: System.get_env("JOIN_TO")
```