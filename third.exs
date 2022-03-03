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
