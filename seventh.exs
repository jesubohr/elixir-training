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


