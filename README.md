# NestedLines

A simple library to facilitate parsing line numbers into a common structure and enabling indenting/outdenting/moving of lines.

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

For a given list of strings, use `NestedLines.new!/1` to parse the strings into a a `%NestedLines{}` struct.

```elixir
lines = ["1", "2", "2.1", "2.2", "3", "3.1", "3.1.1"] |> NestedLines.new!()

# %NestedLines{lines: [[1], [1], [0, 1], [0, 1], [1], [0, 1], [0, 0, 1]]}
```

With a `%NestedLines{}` stuct, you can then output the line numbers using `NestedLines.line_numbers/2`

```elixir
%NestedLines{lines: [[1], [0, 1], [0, 1], [1], [0, 1], [0, 0, 1], [1], [1]]} |> NestedLines.line_numbers()

# ["1", "1.1", "1.2", "2", "2.1", "2.1.1", "3", "4"]
```

💡 Use the optional second argument to start the lines at a different number.

### TODO

* Move child lines when indenting/outdenting
* Move lines between siblings
* Move lines anywhere?
