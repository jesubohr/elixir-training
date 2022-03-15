defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    bucket = start_supervised!(KV.Bucket)
    %{bucket: bucket}
  end

  test "Stores keys by Values", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "cookie") == nil

    KV.Bucket.put(bucket, "cookie", 5)
    assert KV.Bucket.get(bucket, "cookie") == 5

    assert KV.Bucket.delete(bucket, "cookie") == 5
  end
  
  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end
