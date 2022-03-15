defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) == :"foo@JamesWooden"
    assert KV.Router.route("world", Kernel, :node, []) == :"bar@JamesWooden"
  end
end
