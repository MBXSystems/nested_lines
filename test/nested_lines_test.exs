defmodule NestedLinesTest do
  use ExUnit.Case
  doctest NestedLines

  describe "nil values" do
    test "nil values return [[1]]" do
      input1 = NestedLines.new!([nil])
      assert %NestedLines{lines: [[1]]} = input1

      input2 = NestedLines.new!(["1", nil, "2"])
      assert %NestedLines{lines: [[1], [1], [1]]} = input2
    end
  end

  describe "string values" do
    test "[\"1\"] returns [[1]]" do
      input = NestedLines.new!(["1"])
      assert %NestedLines{lines: [[1]]} = input
    end

    test "[\"1\", \"2\"] returns [[1], [1]]" do
      input = NestedLines.new!(["1", "2"])
      assert %NestedLines{lines: [[1], [1]]} = input
    end

    test "[\"1\", \"1.1\", \"1.2\"] returns [[1], [0, 1], [0, 1]]" do
      input = NestedLines.new!(["1", "1.1", "1.2"])
      assert %NestedLines{lines: [[1], [0, 1], [0, 1]]} = input
    end
  end

  describe "numeric values" do
    test "numeric values return [[1]]" do
      input = NestedLines.new!([nil])
      assert %NestedLines{lines: [[1]]} = input

      input2 = NestedLines.new!(["1", 1, "2"])
      assert %NestedLines{lines: [[1], [1], [1]]} = input2

      input3 = NestedLines.new!(["1", 1.1, "2", 2.1])
      assert %NestedLines{lines: [[1], [0, 1], [1], [0, 1]]} = input3
    end
  end
end
