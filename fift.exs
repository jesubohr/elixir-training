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
