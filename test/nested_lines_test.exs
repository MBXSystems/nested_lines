defmodule NestedLinesTest do
  use ExUnit.Case
  doctest NestedLines

  describe "new" do
    test "with valid inputs" do
      nested1 = NestedLines.new(["1", "2", "3"])
      assert {:ok, %NestedLines{lines: [[1], [1], [1]]}} = nested1

      nested2 = NestedLines.new(["1", "1.1", "2"])
      assert {:ok, %NestedLines{lines: [[1], [0, 1], [1]]}} = nested2

      nested3 = NestedLines.new(["1", "1.1", "1.1.1", "2"])
      assert {:ok, %NestedLines{lines: [[1], [0, 1], [0, 0, 1], [1]]}} = nested3
    end

    test "with invalid inputs -- initial line with bad nesting" do
      nested = NestedLines.new(["1.1", "1.2", "2.0", "2.1"])
      assert {:error, :invalid_initial_line_nesting} = nested
    end

    test "with invalid inputs -- non-initial line with bad nesting" do
      # We're allowing this to pass, and the line 2.1 and it's siblings
      # get absorbed into the previous parent line's children.
      nested3 = NestedLines.new(["1", "1.1", "2.1", "2.2"])
      assert {:ok, %NestedLines{lines: [[1], [0, 1], [0, 1], [0, 1]]} = res} = nested3
      assert res |> NestedLines.line_numbers() == ["1", "1.1", "1.2", "1.3"]
    end

    test "with invalid inputs - empty list" do
      assert {:error, :invalid_inputs_empty} = NestedLines.new([])
    end

    test "with invalid inputs - bad input type" do
      assert {:error, :invalid_list} = NestedLines.new("1.1")
    end

    test "with invalid inputs - [\"0\"]" do
      # We strip leading zeroes, so this turns into an empty list
      assert {:error, :invalid_nested_line_inputs} = NestedLines.new(["0"])
    end

    test "with invalid inputs - [\"0.1\"]" do
      # We strip leading zeroes, so this turns into line "1"
      assert {:ok, %NestedLines{lines: [[1]]} = res} = NestedLines.new(["0.1"])
      assert res |> NestedLines.line_numbers() == ["1"]
    end
  end

  describe "parsing nil values" do
    test "nil values return []" do
      input1 = NestedLines.new!([nil])
      assert %NestedLines{lines: [[]]} = input1

      input2 = NestedLines.new!(["1", nil, "2"])
      assert %NestedLines{lines: [[1], [], [1]]} = input2
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

    test "~W(1 1.00 1.01 1.02 1.03) returns [[1], [1], [0, 1], [0, 1], [0, 1]]" do
      input = NestedLines.new!(["1", "1.00", "1.01", "1.02", "1.03"])
      assert %NestedLines{lines: [[1], [1], [0, 1], [0, 1], [0, 1]]} = input
    end
  end

  describe "parsing numeric values" do
    test "numeric values return [[1]]" do
      input = NestedLines.new!(["1", 1, "2"])
      assert %NestedLines{lines: [[1], [1], [1]]} = input

      input1 = NestedLines.new!(["1", 1.1, "2", 2.1])
      assert %NestedLines{lines: [[1], [0, 1], [1], [0, 1]]} = input1
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

    test "skipped line numbers" do
      lines = NestedLines.new!(["1", nil, "3", "4"])
      assert ["1", nil, "2", "3"] = NestedLines.line_numbers(lines)
    end

    test "line numbers with grandchildren" do
      lines = NestedLines.new!(["1", "1.1", "2", "3", "3.1", "3.1.1", "4"])
      assert ["1", "1.1", "2", "3", "3.1", "3.1.1", "4"] = NestedLines.line_numbers(lines)
    end

    test "return line numbers with other starting number" do
      lines = NestedLines.new!(["1", "1.1", "2"])
      assert ["10", "10.1", "11"] = NestedLines.line_numbers(lines, 10)
    end

    test "skipped nested line numbers" do
      lines = NestedLines.new!(["1", "1.1", nil, "1.3", "2", "2.1"])
      assert ["1", "1.1", nil, "1.2", "2", "2.1"] = NestedLines.line_numbers(lines)
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

    test "indent one level with skipped line" do
      lines = NestedLines.new!(["1", nil, "3"])

      assert ["1", nil, "1.1"] =
               NestedLines.indent!(lines, 3)
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

  describe "has_children?" do
    test "with children" do
      has_children = NestedLines.new!(["1", "1.1", "2"]) |> NestedLines.has_children?(1)
      assert has_children
    end

    test "with grandchildren" do
      has_children = NestedLines.new!(["1", "1.1", "1.1.1"]) |> NestedLines.has_children?(2)
      assert has_children
    end

    test "with the last element of the list" do
      has_children = NestedLines.new!(["1", "1.1", "1.1.1"]) |> NestedLines.has_children?(3)
      assert !has_children
    end

    test "with a skipped line" do
      has_children = NestedLines.new!(["1", nil, "2"]) |> NestedLines.has_children?(2)
      assert !has_children
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

    test "with skipped lines" do
      line_numbers = ["1", "2", "2.1", nil, "2.2", "2.2.1", "2.3", nil]
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
