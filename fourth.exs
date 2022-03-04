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
