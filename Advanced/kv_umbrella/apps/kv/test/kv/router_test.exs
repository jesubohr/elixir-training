defmodule KV.RouterTest do
  use ExUnit.Case

  setup_all do
    current = Application.get_env(:kv, :routing_table)

    Application.put_env(:kv, :routing_table, [
      {?a..?m, :"foo@JamesWooden"},
      {?n..?z, :"bar@JamesWooden"}
    ])

    on_exit(fn -> Application.put_env(:kv, :routing_table, current) end)
  end

  @tag :distributed
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) == :"foo@JamesWooden"
    assert KV.Router.route("world", Kernel, :node, []) == :"bar@JamesWooden"
  end
end
