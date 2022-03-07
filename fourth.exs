# Enumerables
# This module provides many useful methods to work with
Enum.map(%{1 => 2, 2 => 3, 3 => 4}, fn {k, v} -> k * v end)
Enum.reduce([1, 2, 3], &*/2)

# Pipe Operator |>
1..10 |> Enum.map(&(&1 * 2)) |> Enum.filter(odd?) |> Enum.sum()

# Streams
# Module that supports lazy operations, like composable enumerables
# Instead of generating lists it returns a stream of the enumerable
# and functions applied to it.
1..10 |> Stream.map(&(&1 * 2)) |> Stream.filter(odd?) |> Enum.sum()

# Creates a stream that cycles a enum indefinitely.
# Not to use with Enum.map as it with loop forever.
stream = Stream.cycle([1, 2, 3])
Enum.take(stream, 5)
# returns [1, 2, 3, 1, 2]

# Creates a stream that generates values from a given one.
stream = Stream.unfold("saluton", &String.next_codepoint/1)
Enum.take(stream, 5)
# returns ["s", "a", "l", "u", "t"]

# Advice:
# Focus on Enums first and just use Stream on particular scenarios
# when laziness is required like big collections, files or slow resources.

# Processes

# Spawn
# Takes a function and execute it in another process
pid = spawn(fn -> 1 + 2 end)
# returns PID<0.44.0>

# Self() retrieve the current process
Process.alive?(self())
# returns true

# Send & Recieve
# Send messages to a process and recieve them
# Messages are stored in process mailbox,
# then 'recieve' searches for a message that matches the given pattern

send(self(), {:hello: "world"})

receive do
  {:hello, msg} -> msg
end
# returns "world"

receive do
  {:hello, msg} -> msg
  after 1_000 -> "Nothing after 1s"
end
# returns "Nothing after 1s" if pattern doesn't match

# Flush
# Flushes all messages in the mailbox and returns :ok
send(self(), :hello)
flush()
# returns :hello & :ok

# Links
# Links a process to another one
spawn_link(fn -> raise "oops" end)

# Tasks
# Like spawn but better for providing errors reports
Task.start(fn -> 1 + 2 end)
Task.start_link(fn -> 1 + 2 end)
# returns {:ok, pid}

# State
# State is a process that can be started, stopped and restarted
defmodule KV do
  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send(caller, Map.get(map, key))
        loop(map)

      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
end
{:ok, pid} = KV.start_link()
# returns {:ok, pid}
Process.register(pid, :kv)
# The process is registered allowing anyone to send messages to it

send(pid, {:put, :foo, "bar"})
send(pid, {:get, :foo, self()})
flush()
# returns "bar"

# Agent are simple abstractions around stateful processes
Agent.start_link(fn -> %{} end, :agent)
Agent.update(:agent, fn map -> Map.put(map, :foo, "bar") end)
Agent.get(:agent, fn map -> Map.get(map, :foo) end)
# returns "bar"

# IO
