# NestedLines

[![Build Status](https://github.com/MBXSystems/simple_xml/workflows/CI/badge.svg)](https://github.com/MBXSystems/nested_lines/actions)
[![Module Version](https://img.shields.io/hexpm/v/nested_lines.svg)](https://hex.pm/packages/nested_lines)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/nested_lines/)
[![Total Download](https://img.shields.io/hexpm/dt/nested_lines.svg)](https://hex.pm/packages/nested_lines)
[![License](https://img.shields.io/hexpm/l/nested_lines.svg)](https://github.com/MBXSystems/nested_lines/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/MBXSystems/nested_lines.svg)](https://github.com/MBXSystems/simple_xml/commits/master)

A simple library to facilitate parsing line numbers into a common structure and enable indenting/outdenting/moving of lines.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nested_lines` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nested_lines, "~> 0.1.0"}
  ]
end
```

## Usage

For a given list of strings, use `NestedLines.new!/1` to parse the strings into a `%NestedLines{}` struct.

```elixir
["1", "2", "2.1", "2.2", "3", "3.1", "3.1.1"]
|> NestedLines.new!()

# %NestedLines{lines: [[1], [1], [0, 1], [0, 1], [1], [0, 1], [0, 0, 1]]}
```

Use `NestedLines.new/1` for return values of `{:ok, %NestedLines{}}` or `{:error, :message}`

```elixir
["1", "2", "2.1"]
|> NestedLines.new()

# {:ok, %NestedLines{lines: [[1], [1], [0, 1]}}
```

```elixir
["1.1", "1.2"]
|> NestedLines.new()

# {:error, :invalid_initial_line_nesting}
```

With a `%NestedLines{}` stuct, you can then output the line numbers using `NestedLines.line_numbers/2`

```elixir
["1", "1.1", "1.2", "2", "2.1", "2.1.1", "3", "4"]
|> NestedLines.new!()
|> NestedLines.line_numbers()

# ["1", "1.1", "1.2", "2", "2.1", "2.1.1", "3", "4"]
```

💡 Use the optional second argument to start the lines at a different number.

Use `NestedLines.indent!/2` and `NestedLines.outdent!/2` to indent and outdent lines, provided they maintain a valid line structure. For example:

```elixir
["1", "2", "3"]
|> NestedLines.new!()
|> NestedLines.indent!(2)
|> NestedLines.line_numbers()
# Here the line at position 2 CAN be indented, resulting in:
# ["1", "1.1", "2"]

["1", "1.1", "2"]
|> NestedLines.new!()
|> NestedLines.indent!(2)
# Here the line at position 2 CANNOT be indented further and will raise an ArgumentError
```

Lines that have children can also be indented/outdented and their child lines will also indent/outdent accordingly by one position.

```elixir
["1", "1.1", "1.1.1", "2"]
|> NestedLines.new!()
|> NestedLines.outdent!(2)
|> NestedLines.line_numbers()
# ["1", "2", "2.1", "3"]

["1", "2", "2.1", "3"]
|> NestedLines.new!()
|> NestedLines.outdent!(2)
# ArgumentError
```


Use `NestedLines.tree` for a representation of the lines as a nested struct. For example:

```elixir
["1", "1.1", "2"]
|> NestedLines.new!()
|> NestedLines.tree()
# [
#  %{line: "1", children: [%{line: "1.1", children: []}]},
#  %{line: "2", children: []}
# ]
```

## Contributing

We welcome merge requests for fixing issues or expanding functionality.

Clone and compile with:

```shell
git clone https://github.com/MBXSystems/nested_lines.git
cd nested_lines
mix deps.get
mix compile
```

Verify that tests and linting pass with your changes.

```shell
mix test
mix lint
```

All code changes should be accompanied with unit tests.