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
