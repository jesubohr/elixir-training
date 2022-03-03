# Keyword Lists
# Used to pass options to functions

String.split("a, b, c", ",", trim: true)
# 'trim' is the key and 'true' the value
[{:trim, true}] == [trim: true]
# This is equivalent
options = [trim: true]
hasTrim = options[:trim]
# Can access values with bracket syntax

# Maps
# Used as the "go to" data structure when key-value stores are needed
# Can use any value as key, and don't follow any order
map = %{:head => 1, 2 => :tail}
# map[:head] = 1, map[2] = :tail
n = 2
map[n]
# returns :tail
Map.get(map, :head)
# returns 1
Map.put(map, 2, :end)
# returns %{2 => :end, :head => 1}
%{map | 2 => :end}
# returns same as previous, so it can be updated like this too

# Do-blocks
# Can be written in oneline expressions too
if true, do: "Executed", else: "Not executed"

# Nested data strcutures
users = [
  james: %{name: "James", age: 21, languages: ["Javascript", "Elixir"]},
  charles: %{name: "Charles", age: 20, languages: ["Python", "Java"]}
]

users[:james].age
# Can be accessed like this, returns 21

users = put_in(users[:james].age, 25)
users = update_in(users[:james].name, fn _ -> "Jesus" end)
# Updating can be done in these two ways

# Modules and Functions
defmodule STR do
  def greet(name) do
    greetPriv(name)
  end

  defp greetPriv(name) do
    "Saluton from mom #{name}"
  end

  def isZero?(0), do: true

  def isNatural?(x) when x > 0 do
    true
  end
end

# Modules group functions in them
# Named functions can be public or private
# Can use guard and multiple clauses too
# The '?' means it returns boolean value

# Function Capturing
# This is a shorcut for creating anonymous functions
fun = &STR.greet/1
fun.("James")
# returns the same output as if we called STR.greet("James")

# Can be used with operators too
subt = &-/2
subt.(3, 2)
# returns 1

# Use &n to capture the nth parameter of the function
greet = &"Saluton #{&1}"
greet.("James")
# returns "Saluton James"
# similar to the syntax 'fn name -> "Saluton #{name}" end'

# Default Values
defmodule Concat do
  def join(a, b \\ nil, sep \\ " ")

  def join(a, b, _sep) when is_nil(b) do
    a
  end

  def join(a, b, sep) do
    a <> sep <> b
  end
end

# Here b is nil and sep is " " if no value is given
# Is recommended to separate a function if it has multiple clauses
# Putting first the function head with the default values
