defmodule NestedLines.MixProject do
  use Mix.Project

  def project do
    [
      app: :nested_lines,
      version: "0.1.6",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A simple library to facilitate parsing line numbers into a common structure and enable indenting/outdenting/moving of lines."
  end

  defp package do
    [
      name: "nested_lines",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/MBXSystems/nested_lines"}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict", "dialyzer"]
    ]
  end
end
