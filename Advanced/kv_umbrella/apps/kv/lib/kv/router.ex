defmodule KV.Router do
  @doc """
  Dispatch the given 'mod', 'fun', 'args' request
  to the appropriate node based on the 'bucket'.
  """
  def route(bucket, mod, fun, args) do
    # Get the first byte of the binary
    first = :binary.first(bucket)

    # Try to find an entry in the table() or raise
    # an exception if it doesn't exist.
    entry =
      Enum.find(table(), fn {enum, _node} ->
        first in enum
      end) || no_entry_error(bucket)

    # If the entry node is the current node
    if elem(entry, 1) == node() do
      apply(mod, fun, args)
    else
      {KV.RouterTasks, elem(entry, 1)}
      |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
      |> Task.await()
    end
  end

  defp no_entry_error(bucket) do
    raise "No entry for bucket #{inspect bucket} in table #{inspect table()}"
  end

  @doc """
  The routing table.
  """
  def table do
    Application.fetch_env!(:kv, :routing_table)
  end
end
