# Alias, Require and Import
# Alias is used to give a new name to an existing module.
defmodule Stats do
  alias Math.List, as: List
  # This allows referring to Math.List module as List in the Stats module.
  # However, the original List module still can be accessed by using Elixir.List.

  # It is lexically scoped, allowing to set aliases within specific functions.
  def add_stat(stat) do
    alias File.Stream
  end
end

alias Math.List
# This sets the alias automatically to the module name.
# This is useful when you want to refer to a module by its name.

# Require is used to load modules that are not available in the current scope.
# It is also lexically scoped.
require Integer
# This will load the Integer module and allow us to use its methods.
Integer.is_odd(3)
# returns true

# Import is used to load modules without using the fully-qualified name.
# It can only import public functions.
# It is also lexically scoped.
import List, only: [duplicate: 2]
# This will load only the duplicate function with arity 2 from the List module.
duplicate(:ok, 3)
# returns [:ok, :ok, :ok]
# Imports are generally discouraged in the Elixir language.
# Prefer using aliases instead.

# Use macro is used as an extension point
# When put 'use' before a module, it allows the module to inject any code
# into the current module. Such as importing itself or other modules.
defmodule Example do
  use SomeModule, option: :value
end

# Since it allows any code to be injected, it needs to be used carefully,
# and only if strictly required. Don't use it instead of alias or import.

# Aliases expand by default to atoms, because the ErlangVM do it this way.
List.flatten([1, [2], 3])
:"Elixir.List".flatten([1, [2], 3])
# both return [1, 2, 3]

# Module nesting
defmodule Salute do
  defmodule Mondo do
  end
end

# Mondo can be accessed as it is while inside Salute.
# If later Mondo is moved outside Salute, it must referenced
# by its full name (Salute.Mondo) or set an alias.
defmodule Salute.Mondo do
end

# This is the same as above. You don't need to define Salute module
# to be able to define Salute.Mondo.

# Multi alias/import/require/use
alias React.{Component, CreateElement}

# -----------------------------------------------------------------------------

# Module attributes
# They serve for three purposes:
# 1. They serve to annotate the module, often with information
#    to be used by the user or the VM.
# 2. They work as constants.
# 3. They work as a temporary module storage to use during compilation.

# As annotations
defmodule MyApp do
  @moduledoc """
  # MyApp module documentation
    Provides a module with a description.
    ```
      iex> MyApp.hello
      "Hello, world!"
    ```
  """
  # Elixir promotes the use of Markdown with heredocs.
  @doc "This is a function documentation."
  def hello do
    "Hello, world!"
  end
end
# The @moduledoc and @doc are by far the most used attributes.
# If you execute "h MyApp.hello" in the Erlang shell,
# it will print "This is a function documentation."

# As constants
defmodule MyApp do
  @constant "This is a constant."
  IO.puts @constant
  # This will print "This is a constant."
end
# They must be defined before trying to access them.

defmodule MyApp.Status do
  @service URI.parse("https://example.com")
  def status(email) do
    ServiceHTTP.get(@service)
  end
end
# The @service function is called at compilation time,
# and its value is then substituted in ServiceHTTP.get function.
# ServiceHTTP.get(%URI{
#   authority: "example.com",
#   host: "example.com",
#   port: 443,
#   scheme: "https"
# })
# This is useful when using pre-computed values. But can be problematic
# if you expect the value to be computed at runtime.
# Elixir takes a snapshot of an attribute every time it is read inside a function.
# So if the value is read multiple times, it will produce multiple copies of it.
# This is a problem when the values are heavy to compute.

# So, instead of this:
def some_func, do: something_do(@value)
def other_func, do: something_else(@value)
# You can do this:
def some_func, do: something_do(values())
def other_func, do: something_else(values())
defp values, do: @value

# Acummulating Attributes
defmodule App do
  Module.register_attribute(__MODULE__, :api, accumulate: true)

  @api :some
  @api :other
  # @api = [:some, :other]
end

# As temporary storage
defmodule MyTest do
  use ExUnit.TestCase, async: true

  @test :external
  @test os: :unix
  test "contacts external service" do
    @api = ServiceHTTP.get(@service)
    assert @api.ok?
  end
end
# In the above example, the async attribute is stored in a module attribute,
# to change how the module is compiled.

# -----------------------------------------------------------------------------

# Structs
# Build on top of maps, they provide compile-time type checking and default values.
# They take the name of the module they are defined in and then acces them
# with map-like syntax.
# Can be used for pattern matching too.
defmodule User do
  defstruct name: "John Doe", age: 18
  # Define two fields with its default values.
  # If not specified, the default value is nil.
end
# Putting this in console: %User{}
# returns this: %User{age: 18, name: "John Doe"}

# When combining fields, nil default values come first.
defmodule User do
  @enforce_keys :name
  defstruct [:email, name: "John Doe", age: 18]
end
# @enforce_keys is an attribute to enforce that certain keys are present.
# If a key is not present, it will raise an error.
# Must be like this: %User{name: "James"}
# to returns this: %User{age: 18, email: nil, name: "James"}
