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
  defstruct name: "James", age: 21
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

# ------------------------------------------------------------------------------

# Comprehensions
# Syntactic sugar for grouping such common operations as filtering,
# mapping, and reducing, into the 'for' keyword.
for n <- [1, 2, 3, 4, 5] do
  n * 2
end

# returns [2, 4, 6, 8, 10]

# It is made of three parts:
# 1. Generators
# 2. Filters
# 3. Collectables

# Generators
# A generator is a function that returns a sequence of values.
# In the example above, 'n <- [1, 2, 3, 4, 5]' generates
# values for the comprehension to iterate over.
# It can be any Enumerable object.
for n <- 1..5, do: n * 2
# returns [2, 4, 6, 8, 10]

# They also support pattern matching on their left-hand side.
values = [:ok: 1, :ok: 2, :error: 3, :ok: 4]
for {:ok, n} <- values, do: n * 2
# returns [2, 4, 8]

# Using filters allow to select only some values from the generator.
for n <- 1..5, rem(n, 2) == 0, do: n * 2
# returns [4, 8]

# Comprehensions also allow multiple generators and filters to be combined.
dirs = ['/home/user', '/home/root']

for dir <- dirs,
    file <- File.ls!(dir),
    path = Path.join(dir, file),
    File.regular?(path) do
  File.stat!(path).size
end
# returns the size of each file in the given directories.

for i <- [:a, :b, :c], j <- [1, 2], do: {i, j}
# returns [a: 1, a: 2, b: 1, b: 2, c: 1, c: 2]

# Bitstring Generators
# Useful when needed to comprehend over bitstrings streams.
pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
for <<r::8, g::8, b::8 <- pixels>>, do: {r, g, b}
# returns [{213, 45, 132}, {64, 76, 32}, {76, 0, 0}, {234, 32, 15}]

# Results of a comprehension can be inserted into different data structures
# with the :into keyword.
# It accepts any data structure that implements the Collectable protocol.
for <<c <- " salute monde ">>, c != ?\s, into: "", do: <<c>>
# returns "salutemonde"

for {key, value} <- %{:a => 1, :b => 2, :c => 3}, into: %{}, do: {key, value * 2}
# returns %{a => 2, b => 4, c => 6}

# ------------------------------------------------------------------------------

# Sigils
# One of the mechanisms for working with textual data.
# They start with the '~' symbol and followed by a letter that represents
# the sigil and then a delimiter. Optionally, modifiers can be added.

# The most common one are regular expressions.
# They support regular used regex modifiers.
"abc" =~ ~r/^[a-z]{3}$/i
# returns true because it is a string of 3 lowercase letters.

# Sigils support 8 different delimiters:
~r/.../
~r|...|
~r"..."
~r'...'
~r(...)
~r[...]
~r{...}
~r<...>
# This is useful to write literals without having escape characters.
# ~r(^https?://) reads better than ~r/^https?:\/\//

# String, charlists, and wordlists

# String sigil are useful to generate strings with double quotes.
~s(This is a string containing "a string" and a 'string')
# returns "This is a string containing \"a string\" and a 'string'"

# Charlist sigil are useful to generate strings with single quotes.
~c(This is a string containing 'a string' and a "string")
# returns 'This is a charlist containing \'single quote text\''

# Wordlist sigil are useful to generate lists of words from any string.
# The words must be separated by whitespaces.
~w(Saluton Mondo)
# returns ["Saluton", "Mondo"]

# They also accepts the c, s & a modifiers.
~w(Saluton Mondo)a
# returns [:Saluton, :Mondo]

# Interpolation and escaping in string Sigils
# Lowercase letters perform escaping and interpolation, while
# uppercase letters do not.

~s(This is a string containing codes \x26 #{1 + 1})
# returns "This is a string containing codes & 2"
~S(This is a string containing codes \x26 #{1 + 1})
# returns "This is a string containing codes \\x26 \#{1 + 1}"

# The following are valid escape codes to use in strings and charlists.
# \\ - backslash
# \a - alert
# \b - backspace
# \d - delete
# \e - escape
# \f - form feed
# \n - newline
# \r - carriage return
# \s - space
# \t - horizontal tab
# \v - vertical tab
# \0 - null byte
# \xDD - hexadecimal code
# \uDDDD & \u{D...} - Unicode codepoint in hexadecimal

# Calendar Sigils

# Date
# It contains fields such as year, month, day, and calendar.
date = ~D[2016-01-01]
date.year
# returns 2016

# Time
# It contains fields such as hour, minute, second, microsecond, and calendar.
time = ~T[12:34:56.789]
time.minute
# returns 34

# Naive DateTime
# It contains fields from both Date and Time.
# It is called 'naive' because it does not contain a timezone.
datetime = ~N[2016-01-01 12:34:56.789]
datetime.microsecond
# returns 789

# UTC DateTime
# It contains fields from both Date and Time with a timezone.
# It is called 'UTC' because it is in the UTC timezone.
datetime = ~U[2016-01-01 12:34:56Z]
%DateTime{minute: minute, time_zone: time_zone} = datetime
~s(minute: #{minute}, time_zone: #{time_zone})
# returns "minute: 34, time_zone: Etc/UTC"

# Custom Sigils
# We can define our own sigils following the 'sigil_{character}' pattern.
defmodule MySigils do
  def sigil_i(string, []) do
    String.to_integer(string)
  end
  # returns the integer value of the string.

  def sigil_i(string, [?n]) do
    -String.to_integer(string)
  end
  # returns the negative integer value of the string.
end
~i(123)
# returns 123
~i(123)n
# returns -123
