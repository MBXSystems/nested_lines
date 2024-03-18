defmodule NestedLinesTest do
  use ExUnit.Case
  doctest NestedLines

  describe "parsing nil values" do
    test "nil values return [[1]]" do
      input1 = NestedLines.new!([nil])
      assert %NestedLines{lines: [[1]]} = input1

      input2 = NestedLines.new!(["1", nil, "2"])
      assert %NestedLines{lines: [[1], [1], [1]]} = input2
    end
  end

  describe "parsing string values" do
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

  describe "parsing numeric values" do
    test "numeric values return [[1]]" do
      input = NestedLines.new!([nil])
      assert %NestedLines{lines: [[1]]} = input

      input2 = NestedLines.new!(["1", 1, "2"])
      assert %NestedLines{lines: [[1], [1], [1]]} = input2

      input3 = NestedLines.new!(["1", 1.1, "2", 2.1])
      assert %NestedLines{lines: [[1], [0, 1], [1], [0, 1]]} = input3
    end
  end

  describe "output lines" do
    test "increment line numbers" do
      lines = %NestedLines{lines: [[1], [1], [1]]}
      assert ["1", "2", "3"] = NestedLines.line_numbers(lines)
    end

    test "increment line numbers with children" do
      lines = %NestedLines{lines: [[1], [0, 1], [1]]}
      assert ["1", "1.1", "2"] = NestedLines.line_numbers(lines)
    end

    test "increment line numbers with grandchildren" do
      lines = %NestedLines{lines: [[1], [0, 1], [1], [1], [0, 1], [0, 0, 1], [1]]}
      assert ["1", "1.1", "2", "3", "3.1", "3.1.1", "4"] = NestedLines.line_numbers(lines)
    end

    test "increment line numbers with other starting number" do
      lines = %NestedLines{lines: [[1], [0, 1], [1]]}
      assert ["10", "10.1", "11"] = NestedLines.line_numbers(lines, 10)
    end

    test "fail if starting_number less than 1" do
      lines = %NestedLines{lines: [[1], [0, 1], [1]]}
      assert_raise FunctionClauseError, fn ->
        ["10", "10.1", "11"] = NestedLines.line_numbers(lines, 0)
      end
    end
  end
end
