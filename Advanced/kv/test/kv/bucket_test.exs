defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "Stores keys by Values", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "cookie") == nil

    KV.Bucket.put(bucket, "cookie", 5)
    assert KV.Bucket.get(bucket, "cookie") == 5

    assert KV.Bucket.delete(bucket, "cookie") == 5
  end
end