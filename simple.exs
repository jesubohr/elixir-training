# Integer
140
# Float
36.5
2.1e-10
# Boolean
true
# Atom/Symbol
:atom
# String
"elixir"
# List
[1, 2, 3]
# Tuple
{1, 2, 3}

# Integer division
div(120, 20)
# Division remainder
rem(30, 5)

# Binary
0b0101
# Octal
0o777
# Hexadecimal
0x1F

# Round to closest integer
round(4.56)
# Retrieves integer part
trunc(4.56)

# Functions to check a value type
is_boolean(true)
is_integer(1)
is_float(2.3)
# etc...

# Atoms
:atom
# true
:atom == :atom
# true
true == true

# Aliases
is_atom(Saluton)

# Strings
string = "Mondo"
# Prints 'Saluton Mondo'
IO.puts("Saluton #{string}")
# Concatenate
"Saluton" <> " Mondo"

# Anonymous Functions, different from named ones
subs = fn a, b -> a - b end
subs.(3, 2)

# (Linked) Lists
[1, 2, true, 3]
# Concat and Subtract Operators
[1, 2, 3] ++ [4, 5, 6]
[1, 2, 3] -- [3, 2, 1]

# ASCII Numbers show themselves as a charlist
[7, 8, 9, 10, 11, 12, 13] # '\a\b\t\n\v\f\r'

# Tuples
tuple = {:ok, "saluton"}
elem(tuple, 1) # return "saluton"
put_elem(tuple, 1, "mondo") # return {:ok, "mondo"}, the value ':ok' is shared
# tuple -> {:ok, "saluton"}
