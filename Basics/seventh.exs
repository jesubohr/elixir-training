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

IEx.break!(Funk.funky() / 3)
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

# ------------------------------------------------------------------------------

# Erlang Libraries

# Binary Module
# Useful when dealing with binary data that is not necessarily
# UTF-8 encoded.
String.to_charlist("Ø")
# [216], it returns Unicode codepoints.
:binary.bin_to_list("Ø")
# [195, 152], it returns raw data bytes.

# Formatted Text Output
# Useful for printing formatted text to the console.
:io.format("Pi value: ~10.3f~n", [:math.pi()])

# Crypto Module
Base.encode16(:crypto.hash(:sha256, "Hello World"))
# returns "A591A6D40BF420404A011733CFB7B190D62C65BF0BCDA32B57B277D9AD9F146E"

# Digraph Module
# Contains function to deal with directed graphs.
digraph = :digraph.new()
coords = [{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}]
[v0, v1, v2] = for c <- coords, do: :digraph.add_vertex(digraph, c)
:digraph.add_edge(digraph, v0, v1)
:digraph.add_edge(digraph, v1, v2)
:diagraph.get_short_path(digraph, v0, v2)
# returns [{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}]

# Erlang Term Storage
# Its modules 'ets' and 'dets' allow to handle storage of large data
# structures in memory or disk.

# The ets module modifies the state of the table as a side-effect.
table = :ets.new(:ets_test, [])
# In this example, information is stored as tuples.
:ets.insert(table, {"China", 1_370_000_000})
:ets.insert(table, {"Mexico", 120_000_000})
:ets.insert(table, {"Colombia", 50_000_000})
:ets.i(table)
# prints an interactive prompt that allows to interact with the table.
# {<<"Mexico">>,120000000}
# {<<"Colombia">>,50000000}
# {<<"China">>,1370000000}


# Math Module
# Contains functions to deal with mathematical operations.
:math.pi()
# returns 3.141592653589793
:math.sqrt(4)
# returns 2.0
:math.exp(1)
# returns 2.718281828459045

# Queue Module
# Implements FIFO queues efficiently.
que = :queue.new()
que = :queue.in("A", que)
que = :queue.in("B", que)
{value, que} = :queue.out(que)
# returns {:value, "A"}
value

# Rand Module
# For generating random numbers and setting random seeds.
:rand.uniform()
# returns 0.0926552308544333
:rand.seed(:exs1024, {123, 123_534, 345_345})
# set the seed
:rand.uniform()
# returns 0.5820506340260994

# Zip and Zlib Modules
# Zip module is useful to read, write & extract information from ZIP files
# from disk or memory.
:zip.foldl(fn _, _, _, acc -> acc + 1 end, 0, :binary.bin_to_list("test.zip"))
# Counts the number of files in the ZIP archive.
# returns {:ok, 3}

# Zlib module is useful to compress and decompress data in zlib format.
compressed = :zlib.compress(:binary.bin_to_list("Lorem ipsum dolor sit amet"))
byte_size(compressed)
# returns 34
byte_size("Lorem ipsum dolor sit amet")
# returns 26
:zlib.uncompress(compressed)
# returns "Lorem ipsum dolor sit amet"
