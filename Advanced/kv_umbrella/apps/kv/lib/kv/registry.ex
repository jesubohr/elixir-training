defmodule KV.Registry do
  use GenServer

  # API Client
  @doc """
  Starts the registry with given options.
  ':name' is always required.
  """
  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Looks up the bucket pid for a given name stored in the server.
  Returns {:ok, pid} if the bucket exists, otherwise :error.
  """
  def lookup(server, name) do
    # Now directly made in ETS without calling the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket for the given name in server.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  # Server callbacks

  @impl true
  def init(table) do
    # Replaced names Map by ETS table
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  # Function handle_call is not neccessary anymore

  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    # Read/Write directly form ETS table
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}
      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # Delete from ETS table
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
