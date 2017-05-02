defmodule Distkv.DkvServer do
    use GenServer
    
    import Process, only: [whereis: 1]
    alias Distkv.Dkv

    require Logger

    def start_link(node_addr \\ nil) do
        GenServer.start_link(__MODULE__, node_addr, name: __MODULE__)
    end

    def run(addr) do
        Node.connect String.to_atom(addr)
    end

    def init(node_addr) do
        case node_addr do
            nil ->
                :ok = :lbm_kv.create(Dkv)
            _   ->
                timeout = 60_000
                worker = Task.async(__MODULE__, :run, [node_addr])
                Task.await(worker, timeout)
                case Node.list do
                    [] ->
                        :ok = :lbm_kv.create(Dkv)
                    _  ->
                        :ok = :mnesia.wait_for_tables([Dkv], 60_000)
                        :ok = :lbm_kv.create(Dkv)
                end
        end
        {:ok, []}
    end

    def insert(key, value) when is_atom(key) do
        pid = whereis(__MODULE__)
        GenServer.call(pid, {:put, key, value})
    end

    def select(key) when is_atom(key) do
        pid = whereis(__MODULE__)
        GenServer.call(pid, {:get, key})
    end

    def delete(key) when is_atom(key) do
        pid = whereis(__MODULE__)
        GenServer.call(pid, {:del, key})
    end

    def update(key, value) when is_atom(key) do
        pid = whereis(__MODULE__)
        GenServer.call(pid, {:upd, key, value})
    end

    def select_all() do
        pid = whereis(__MODULE__)
        GenServer.call(pid, :all)
    end

    def handle_call({:put, key, value}, _from, args) do
        {:ok, value} = :lbm_kv.put(Dkv, key, value)
        {:reply, :ok, args}
    end

    def handle_call({:get, key}, _from, args) do
        {:ok, value} = :lbm_kv.get(Dkv, key)
        {:reply, value[key], args}
    end

    def handle_call({:del, key}, _from, args) do
        {:ok, value} = :lbm_kv.del(Dkv, key)
        {:reply, :ok, args}
    end

    def handle_call({:upd, key, value}, _from, args) do
        {:ok, value} = :lbm_kv.update(Dkv, key, value)
        {:reply, value[key], args}
    end

    def handle_call(:all, _from, args) do
        {:atomic, keys} = :mnesia.transaction fn -> :mnesia.all_keys(Dkv) end
        records = _select_all(keys, [])
        {:reply, records, args}
    end

    defp _select_all([], list) do
        list
    end

    defp _select_all([h|t], list) do
        {:ok, value} = :lbm_kv.get(Dkv, h)
        nlist = list ++ [value[h]]
        _select_all(t, nlist)
    end

end