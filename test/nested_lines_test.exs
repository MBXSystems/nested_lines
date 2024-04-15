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
    test "~W(1) returns [[1]]" do
      input = NestedLines.new!(["1"])
      assert %NestedLines{lines: [[1]]} = input
    end

    test "~W(1 2) returns [[1], [1]]" do
      input = NestedLines.new!(["1", "2"])
      assert %NestedLines{lines: [[1], [1]]} = input
    end

    test "~W(1 1.1 1.2) returns [[1], [0, 1], [0, 1]]" do
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

  describe "output line numbers" do
    test "flat list of lines numbers" do
      lines = NestedLines.new!(["1", "2", "3"])
      assert ["1", "2", "3"] = NestedLines.line_numbers(lines)
    end

    test "line numbers with children" do
      lines = NestedLines.new!(["1", "1.1", "2"])
      assert ["1", "1.1", "2"] = NestedLines.line_numbers(lines)
    end

    test "line numbers with grandchildren" do
      lines = NestedLines.new!(["1", "1.1", "2", "3", "3.1", "3.1.1", "4"])
      assert ["1", "1.1", "2", "3", "3.1", "3.1.1", "4"] = NestedLines.line_numbers(lines)
    end

    test "return line numbers with other starting number" do
      lines = NestedLines.new!(["1", "1.1", "2"])
      assert ["10", "10.1", "11"] = NestedLines.line_numbers(lines, 10)
    end

    test "fail if starting_number less than 1" do
      lines = NestedLines.new!(["1", "1.1", "2"])

      assert_raise FunctionClauseError, fn ->
        NestedLines.line_numbers(lines, 0)
      end
    end
  end

  describe "indent lines" do
    test "indent one level" do
      lines = NestedLines.new!(["1", "2", "3"])

      assert ["1", "1.1", "2"] =
               NestedLines.indent!(lines, 2)
               |> NestedLines.line_numbers()
    end

    test "indent two levels" do
      lines = NestedLines.new!(["1", "1.1", "1.2"])

      assert ["1", "1.1", "1.1.1"] =
               NestedLines.indent!(lines, 3)
               |> NestedLines.line_numbers()
    end

    test "cannot indent further than two levels" do
      lines = NestedLines.new!(["1", "1.1"])

      assert_raise ArgumentError, fn ->
        NestedLines.indent!(lines, 2)
      end
    end

    test "indent with child" do
      lines = NestedLines.new!(["1", "2", "2.1"])

      assert ["1", "1.1", "1.1.1"] =
               NestedLines.indent!(lines, 2)
               |> NestedLines.line_numbers()
    end
  end

  describe "outdent lines" do
    test "outdent one level" do
      lines = NestedLines.new!(["1", "1.1", "1.2"])

      assert ["1", "1.1", "2"] =
               NestedLines.outdent!(lines, 3)
               |> NestedLines.line_numbers()
    end

    test "outdent two levels" do
      lines = NestedLines.new!(["1", "1.1", "1.1.1"])

      assert ["1", "1.1", "1.2"] =
               NestedLines.outdent!(lines, 3)
               |> NestedLines.line_numbers()
    end

    test "cannot outdent beyond top-level" do
      lines = NestedLines.new!(["1", "1.1", "1.1.1"])

      assert_raise ArgumentError, fn ->
        NestedLines.outdent!(lines, 1)
      end
    end

    test "outdent with child" do
      lines = NestedLines.new!(["1", "1.1", "1.1.1"])

      assert ["1", "2", "2.1"] =
               NestedLines.outdent!(lines, 2)
               |> NestedLines.line_numbers()
    end
  end

  describe "tree" do
    test "with deeply nested children" do
      line_numbers = ["1", "2", "2.1", "2.2", "2.2.1", "2.3"]
      lines = NestedLines.new!(line_numbers)

      assert [
               %{line: "1", children: []},
               %{
                 line: "2",
                 children: [
                   %{
                     line: "2.1",
                     children: []
                   },
                   %{
                     line: "2.2",
                     children: [
                       %{
                         line: "2.2.1",
                         children: []
                       }
                     ]
                   },
                   %{
                     line: "2.3",
                     children: []
                   }
                 ]
               }
             ] = NestedLines.tree(lines)
    end
  end
end
