defmodule KV.Bucket do
  use Agent, restart: :temporary

  @doc """
  Starts a new Bucket
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the 'bucket' by the 'key'
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the 'value' to the 'bucket' by the 'key'
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Delete the element from the 'bucket' by the 'key'
  Returns the deleted value
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
