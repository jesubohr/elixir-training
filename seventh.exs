# Try, catch and rescue
# Elixir has three different error mechanisms: errors, throws and exits.

# Errors (or exceptions)
# Used when exceptional conditions occur.
:foo + 1
# ** (ArithmeticError) bad argument in arithmetic expression
#      :erlang.+(:foo, 1)

# Raise can be used also to raise exceptions
raise RuntimeError, "something bad happened"
# ** (RuntimeError) something bad happened

# We can also define our own exceptions
defmodule MyError do
  defexception message: "My error message"
end

raise MyError
# ** (MyError) My error message
raise MyError, message: "A custom message"
# ** (MyError) A custom message

# Errors can be rescued using the try/rescue mechanism
# They are rarely used, but they are very useful when you want to handle
# exceptions in a specific way.
try do
  raise RuntimeError, "something bad happened"
rescue
  e in RuntimeError -> e
end

# returns %RuntimeError{message: "something bad happened"}

# Reraise
# Although not generally used, try/rescue is very useful when doing
# observability/monitoring.
try do
  # some code
rescue
  e ->
    Logger.error(Exception.format(:error, e, __STACKTRACE__))
    reraise e, __STACKTRACE__
end

# This is useful when intercepting an exception, do something,
# and re-raise it again with its original stacktrace, as if it
# was never intercepted.

# Throw
# Used when it's not possible to retrieve a value unless we use it.
try do
  Enum.each(-40..40, fn x ->
    if rem(x, 13) == 0 do
      throw({:done, x})
    end
  end)
catch
  {:done, x} -> "Got exception: #{x}"
end

# This would be in the case that Enum (or any other module we were using) didn't
# provide a proper API.

# Exit
# A signal returned when a process ends, or when commanding a process to end.
# They play an great role in fault tolerant system provided by the Erlang VM.
spawn_link(fn -> exit(1) end)
# This will end the linked process with exit code 1.
# The supervision tree will be notified of this, and will restart the process.

# After
# When we want to do something after an action has finished, without
# caring if it succeeded or not.
{:ok, file} = File.open("/etc/passwd", [:utf8, :write])

try do
  IO.write(file, "Hello")
  raise "Something bad happened"
after
  File.close(file)
end

# The after clause will be executed even if the try clause failed.
# However, after only provides a soft guarantee, not getting run
# when linked process exits.

defmodule Util do
  def runit do
    IO.puts("Running Kernel...")
  after
    IO.puts("Done")
  end
end

# Elixir allows you use rescue/after/catch in functions, without
# having to wrap them in a try construct.

# Else
# To match the results of the try clause when it finishes whitout
# a throw or an error.
x = 2

try do
  1 / x
rescue
  ArithmeticError -> :infinity
else
  y when y < 1 and y > -1 -> :small
  _ -> :large
end

# returns :small

# ------------------------------------------------------------------------------

# Types and Specs
# Being dynamic, Elixir check the types of variables at runtime.
# Thus, it comes with typespecs which are used for:
# 1. Declaring typed functions signatures
# 2. Declaring custom types

# Function signatures
# Functions specs are written with @spec
round(number()) :: integer()
# The syntax is: function_name(arg1, arg2, ...) :: return_type
# Return types may omit parentheses.

# Defining Custom Types
# It can help communicate the intention of the code, and make it easier
# to understand.
defmodule MyDate do
  @typedoc """
  A regional formatted date.
  """
  @type date :: {integer(), integer(), integer()}

  @spec now() :: date
  def now() do
    %Date{day: d, month: m, year: y} = Date.utc_today()
    "#{d}/#{m}/#{y}"
  end
end

# Behaviours
# They provide a way to define and ensure that functions of a specific
# set will be implemented by a given module.
# Similar to Interfaces in other languages.
defmodule Parser do
  @doc "Parses a string"
  @callback parse(String.t()) :: {:ok, term()} | {:error, String.t()}

  @doc "List supported file extensions"
  @callback extensions() :: [String.t()]
end

# Modules that implement the Parser behaviour will have to implement
# both the parse and the extensions functions.
# If a module doesn't implement a function, a warning will be raised.
defmodule JSONParser do
  @behaviour Parser

  @impl Parser
  def parse(string), do: {:ok, "Parsed JSON" <> string}

  @impl Parser
  def extensions(), do: ["json"]
end

# Dynamic Dispatch
# Behaviours and them often go hand in hand.
defmodule Parser do
  @callback parse(String.t()) :: {:ok, term()} | {:error, String.t()}
  @callback extensions() :: [String.t()]

  def parse!(implementation, contents) do
    case implementation.parse(contents) do
      {:ok, data} -> data
      {:error, message} -> raise ArgumentError, "Error parsing: #{message}"
    end
  end
end

# The function parse! will dispatch to the given parse implementation
# and return the result or raise an exception if case of error.

# ------------------------------------------------------------------------------

# Debugging
# Here we have some of the most commons ways of debugging.

# IO.inspect
# It allows to inspect on values without altering them.
# It also allow us to provide a custom label for the value.
1..10
|> IO.inspect(label: "Range")
|> Enum.map(fn x -> x * 2 end)
|> IO.inspect(label: "Doubled")
|> Enum.sum()
|> IO.inspect(label: "Sum")

# Range: 1..10
# Doubled: [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
# Sum: 110

# It is common to use IO.inspect with binding() to return
# all variables names and values.
def funky(a, b, c) do
  IO.inspect(binding())
end

# When called with funky(:foo, "bar", 'baz'),
# it returns [a: :foo, b: "bar", c: 'baz']

# IEx.pry and IEx.break!
# IEx.pry is a convenient way to access all variables, imports,
# aliases, etc., from the code. While running, code execution
# stops until 'continue' is called in IEx.
def funky(a, b, c) do
  require IEx
  IEx.pry()
end

# IEx.break! allows to set breakpoints without modifying the code.
# While running, code execution also stops until 'continue' is called.
# However, it does not have access to the imports and aliases because
# it works on the compiled artifact rather than the source code.
defmodule Funk do
  def funky(a, b, c) do
    {a, b, c}
  end
end
IEx.break!(Funk.funky/3)
# When Funk.funky(:foo, "bar", 'baz') is called, code execution
# will stop at the function definition.

# Debugger
# It allows us to debug code with a GUI.

defmodule Example do
  def double_sum(x, y) do
    hard_work(x, y)
  end

  defp hard_work(x, y) do
    x = 2 * x
    y = 2 * y

    x + y
  end
end

:debugger.start()
# This will start a debugger session.
:int.ni(Example)
# This will prepare the Example module for debugging.
:int.break(Example, 3)
# This will set a breakpoint at the third line of the module.
Example.double_sum(1, 2)
# This will run the module and stop at the breakpoint. Allowing
# us to inspect the variables and the stacktrace.

# Observer
# Useful for debugging complex systems where it is necessary to have
# an understanding of the whole virtual machine, processes, applications,
# and tracing mechanisms.

:observer.start()
# It opens a GUI that provides a visual representation of the runtime
# and the project to navigate through and understand.
