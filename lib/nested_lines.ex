defmodule NestedLines do
  @moduledoc """
  Documentation for `NestedLines`.
  """

  defstruct lines: []

  @type line_number :: 0..1

  @type line :: [line_number()]

  @type t :: %__MODULE__{
          lines: [line()]
        }

  @doc """
  Construct a nested line representation from a list of string values.

  ## Examples

      iex> NestedLines.new!(["1", "1.1", "1.2", "2", "2.1"])
      %NestedLines{lines: [[1], [0, 1], [0, 1], [1], [0, 1]]}

  """
  @spec new!(list(String.t() | non_neg_integer())) :: t
  def new!(line_input) when is_list(line_input) do
    lines = Enum.map(line_input, &parse_input/1)
    %__MODULE__{lines: lines}
  end

  def new!(_), do: raise(ArgumentError, "cannot build NestedLines, invalid input")

  @spec parse_input(any()) :: line()

  defp parse_input(line) when is_number(line), do: to_string(line) |> parse_input()

  defp parse_input(line) when is_binary(line) do
    line
    |> String.split(".", trim: true)
    |> convert_to_binary_list([])
  end

  defp parse_input(_), do: [1]

  @spec convert_to_binary_list(list(String.t()), line()) :: line()
  defp convert_to_binary_list([], list), do: list

  defp convert_to_binary_list([_head | [] = tail], list) do
    convert_to_binary_list(tail, list ++ [1])
  end

  defp convert_to_binary_list([_head | tail], list) do
    convert_to_binary_list(tail, [0 | list])
  end

  @doc """
  Output a string representation of the line numbers.

  ## Examples

      iex> %NestedLines{lines: [[1], [0, 1], [0, 1], [1], [0, 1], [0, 0, 1]]} |> NestedLines.line_numbers()
      ["1", "1.1", "1.2", "2", "2.1", "2.1.1"]

  """
  @spec line_numbers(t, pos_integer()) :: list(String.t())
  def line_numbers(%__MODULE__{lines: lines}, starting_number \\ 1) when starting_number > 0 do
    build_line_numbers(lines, [starting_number - 1], [])
  end

  defp build_line_numbers([], _prev, output), do: join_line_numbers(output)

  defp build_line_numbers([current | rest], prev, output) do
    next =
      current
      |> Enum.zip(prev ++ [0])
      |> Enum.map(fn {a, b} -> a + b end)

    build_line_numbers(rest, next, output ++ [next])
  end

  defp join_line_numbers(line_numbers), do: Enum.map(line_numbers, &Enum.join(&1, "."))

  @doc """
  Returns true if the line can be indented, false otherwise. Lines are 1-indexed.

  ## Examples

      iex> %NestedLines{lines: [[1], [0, 1], [0, 1]]} |> NestedLines.can_indent?(1)
      false

      iex> %NestedLines{lines: [[1], [0, 1], [0, 1]]} |> NestedLines.can_indent?(3)
      true

  """
  @spec can_indent?(t, pos_integer()) :: boolean()
  def can_indent?(%__MODULE__{lines: lines}, position)
      when is_integer(position) and position > 0 do
    lines
    |> Enum.slice(position - 2, 2)
    |> can_indent?()
  end

  defp can_indent?([prev, next]) when length(prev) >= length(next), do: true
  defp can_indent?(_), do: false

  @doc """
  Indents a line based on its index, raises if the line cannot be indented.
  Child lines are also indented by one position. Lines are 1-indexed.

  ## Examples

      iex> %NestedLines{lines: [[1], [1], [0, 1], [1]]} |> NestedLines.indent!(4)
      %NestedLines{lines: [[1], [1], [0, 1], [0, 1]]}

  """
  @spec indent!(t, pos_integer()) :: t
  def indent!(%__MODULE__{lines: lines} = nested_lines, position)
      when is_integer(position) and position > 0 do
    case can_indent?(nested_lines, position) do
      true -> do_indent(lines, position)
      false -> raise(ArgumentError, "cannot indent line at #{position}")
    end
  end

  defp do_indent(lines, position) do
    # split the lines into three parts: front, back, and the line to be indented
    {front, [line_item | rest]} = Enum.split(lines, position - 1)

    {child_lines, back} = split_child_lines(rest, length(line_item))

    updated_lines =
      [line_item | child_lines]
      |> indent_lines()
      |> then(fn indented_lines -> [front, indented_lines, back] end)
      |> Enum.concat()

    %__MODULE__{lines: updated_lines}
  end

  @doc """
  Returns true if the line can be outdented, false otherwise. Lines are 1-indexed.

  ## Examples

      iex> %NestedLines{lines: [[1], [0, 1], [0, 0, 1]]} |> NestedLines.can_outdent?(2)
      true

      iex> %NestedLines{lines: [[1], [0, 1], [1]]} |> NestedLines.can_outdent?(3)
      false

  """
  @spec can_outdent?(t, pos_integer()) :: boolean()
  def can_outdent?(%__MODULE__{lines: lines}, position)
      when is_integer(position) and position > 0 do
    lines
    |> Enum.slice(position - 1, 2)
    |> can_outdent?()
  end

  defp can_outdent?([[1], _next]), do: false
  defp can_outdent?([current, next]) when length(current) <= length(next), do: true
  defp can_outdent?([list]) when length(list) > 1, do: true
  defp can_outdent?(_), do: false

  @doc """
  Outdents a line based on its index, raises if the line cannot be outdented.
  Child lines are also outdented by one position. Lines are 1-indexed.

  ## Examples

      iex> %NestedLines{lines: [[1], [1], [0, 1], [0, 0, 1]]} |> NestedLines.outdent!(3)
      %NestedLines{lines: [[1], [1], [1], [0, 1]]}

  """
  def outdent!(%__MODULE__{lines: lines} = nested_lines, position)
      when is_integer(position) and position > 0 do
    case can_outdent?(nested_lines, position) do
      true -> do_outdent(lines, position)
      false -> raise(ArgumentError, "cannot outdent line at #{position}")
    end
  end

  defp do_outdent(lines, position) do
    # split the lines into three parts: front, back, and the line to be outdented
    {front, [line_item | rest]} = Enum.split(lines, position - 1)

    {child_lines, back} = split_child_lines(rest, length(line_item))

    updated_lines =
      [line_item | child_lines]
      |> outdent_lines()
      |> then(fn outdented_lines ->
        [front, outdented_lines, back]
      end)
      |> Enum.concat()

    %__MODULE__{lines: updated_lines}
  end

  defp split_child_lines(lines, parent_length) do
    Enum.split_while(lines, fn line -> length(line) > parent_length end)
  end

  defp outdent_lines(lines), do: Enum.map(lines, fn [0 | line] -> line end)
  defp indent_lines(lines), do: Enum.map(lines, &[0 | &1])
end
