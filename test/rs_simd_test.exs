defmodule RsSimdTest do
  use ExUnit.Case

  test "encode and decode" do
    original = [
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
      "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut e",
      "nim ad minim veniam, quis nostrud exercitation ullamco laboris n"
    ]

    # Encode
    {:ok, recovery} = RsSimd.encode(3, 5, original)
    assert length(recovery) == 5

    # Assume original shards 0 and 2 are lost
    provided_original = [{1, Enum.at(original, 1)}]
    provided_recovery = [{1, Enum.at(recovery, 1)}, {4, Enum.at(recovery, 4)}]

    # Decode
    {:ok, restored} = RsSimd.decode(3, 5, provided_original, provided_recovery)

    assert restored[0] == Enum.at(original, 0)
    assert restored[2] == Enum.at(original, 2)
  end

  test "correct repairs the original message" do
    original = [
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do ",
      "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut e",
      "nim ad minim veniam, quis nostrud exercitation ullamco laboris n"
    ]

    # Encode
    {:ok, recovery} = RsSimd.encode(3, 5, original)
    assert length(recovery) == 5

    # Assume original shards 0 and 2 are lost
    provided_original = [{1, Enum.at(original, 1)}]
    provided_recovery = [{1, Enum.at(recovery, 1)}, {4, Enum.at(recovery, 4)}]

    # Decode
    {:ok, restored} = RsSimd.correct(3, 5, provided_original, provided_recovery)

    assert Enum.at(restored,0) == Enum.at(original, 0)
    assert Enum.at(restored,2) == Enum.at(original, 2)
  end
end
