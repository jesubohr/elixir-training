# Protocols
# A mechanism to achieve polymorphism in Elixir,
# depending on the type of the value.
# They help us to extend the expected behaviour of the functions
# we create to as many data types as possible.
defprotocol Size do
  @doc "Determines the size of a data structure."
  def size(data)
end
# This allows us to define as many implementations for the Size protocol,
# whenever and wherever we want. Not having to modify the module each time,
# just need to add a new implementation (even spread over multiple files).
# The dispatch of the implementation depends on the type of the first argument.

defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end

defimpl Size, for: Map do
  def size(map), do: map_size(map)
end

defimpl Size, for: Tuple do
  def size(tuple), do: tuple_size(tuple)
end

# Structs require their own protocol implementation.
# If needed, we can define our own semantics for the protocols
# for the structs we create.
defmodule User do
  defstruct [name: "James", age: 21]
end

defimpl Size, for: User do
  def size(_user), do: 2
end

# Deriving vs Fallback
# Having this implementation
defimpl Size, for: Any do
  def size(_), do: 0
end

# To derive any protocol implementation based on the Any implementation
# we explicitly tell our struct to derive the Size protocol.
# It will use the Size protocol based on the Any implementation.
defmodule OtherUser do
  @derive [Size]
  defstruct [:nickname, :picture]
end


# To fallback to the Any implementation when an implementation is not found.
# Now all data types that don't have an implementation for the Size protocol
# will use the Any implementation.
defprotocol Size do
  @fallback_to_any true
  def size(data)
end
