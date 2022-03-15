# Match Operator
# Used to pattern match inside data structures

x = 1
1 = x
# The variable matchs, so it's a valid expression. Not used to assigment

# Pattern Matching
# Useful with destructuring
# Both sides have to be of same size and same type

{a, b, c} = {:ok, "mondo", 45}
# a = :ok, b = "mondo", c = 45

[a, b, c] = [1, 2, 3]
# a = 1, b = 2, c = 3

# Fixed values can be used to assert certain cases
{:ok, result} = {:ok, "Saluton"}
# result = "Saluton" if the right side begin with :ok

# List support matching own head & tail
[head | tail] = [1, 2, 3]
# head = 1, tail = [2, 3]

# Also support prepending items to list
list = [1, 2, 3]
[0 | list]
# [0, 1, 2, 3]

# Pin Operator
# Used to avoid rebinding a variable, so the '=' acts as match operator
x = 1
^x = 2
# Throw error because 1 != 2

[head | _] = [1, 2, 3]
# head = 1, and _ cannot be read from.

# Case, Cond & If
# Comparing a value against many patterns
# If no clause matches it throws an error
case [1, 2, 3] do
  [4, 5, 6] ->
    "I won't match"

  [a, b, c] ->
    "I match and a,b,c are equal to 1,2,3"

  [^x, 2, 3] ->
    "I match to existing variable x"

  _ ->
    "I match any value"

  [1, a, 3] when a > 1 ->
    "I match only if guard condition is satisfied"
end

# Anonymous functions can have guards too
func = fn
  x, y when x > 0 -> x + y
  x, y -> x - y
end

# When need to find the first one that doesn't evuale to nil or false
# Equivalent to else if in other languages
# It considers every value (besides nil and false) as true
cond do
  2 * 2 == 5 ->
    "Not true"

  3 * 1 == 4 ->
    "Nor this"

  9 - 3 == 6 ->
    "This is it"

  true ->
    "I am a default case (equivalent to else)"
end

# When checking one condition only
if is_atom(:ok) do
  "I am #{:ok}"
else
  "I am not #{:ok}"
end

unless is_boolean(:not) do
  "I am not a boolean!"
end

# Unicode & Code Points
# Use ? infront of character literal to reveal its codepoint
?a

# To write any unicode use \u and the hex representation of the codepoint
"\u0061"

# Bitstrings
# Contiguous sequence of bits in memory
<<0::1, 0::1, 0::1, 0::1>> == <<3::4>>
# Number 3 in binary 0011 stores in 4 bits
# Any value exceeding max storage is truncated

# Binaries
# A bitstring of 8 bits
is_bitstring(<<3::4>>)
# True
is_binary(<<3::4>>)
# False

is_bitstring(<<0, 255, 42>>)
# True
is_binary(<<42::16>>)
# True

# Also supports pattern matching
<<0, 1, x>> = <<0, 1, 2>>
# x = 2
<<0, 1, x::binary>> = <<0, 1, 2, 3>>
# When matching a binary of unknown size
<<head::binary-size(2), tail::binary>> = <<0, 1, 2, 3>>
# Selecting a specific number of bytes
<<head, tail::binary>> = "banana"
# Strings are also binaries
<<head::utf8, tail::binary>> = "über"

# Charlists
# List of integers where all of them are valid codepoints
# Created with single quotes
'hełło'
# result in [104, 101, 322, 322, 111]

'hello ' ++ 'world'
# They concatenate like lists
