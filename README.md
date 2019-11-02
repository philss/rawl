# Rawl

It is a importers generator that aims to help people to import CSV
files directly to the database.

Rawl will create migrations with tables that are a guess of the types
from the CSV file. It will define the schema that is most likely what
you will use in your production table.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rawl` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rawl, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/rawl](https://hexdocs.pm/rawl).

## License

This project is under MIT license.
