defmodule Mix.Tasks.Rawl.Gen.Migration do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates a new migration for the CSV file"

  @switches [
    schema: :string,
    separator: :string,
    lines: :integer
  ]

  @aliases [
    r: :repo
  ]

  @ecto_switches [
    repo: [:string, :keep],
    no_compile: :boolean,
    no_deps_check: :boolean
  ]

  @impl true
  def run(args) do
    with {opts, [file_path]} <-
           OptionParser.parse!(args, strict: @switches ++ @ecto_switches, aliases: @aliases),
         true <- File.exists?(file_path) do
      Mix.shell().info("Creating a migration for file #{file_path}")
      schema = Keyword.fetch!(opts, :schema)

      changes =
        changes_template(
          columns: Rawl.infer_csv_types!(file_path, inferation_opts(opts)),
          schema: schema
        )

      ecto_opts =
        opts
        |> Keyword.drop(Keyword.keys(@switches))
        |> OptionParser.to_argv(strict: @ecto_switches, aliases: @aliases)

      Mix.Tasks.Ecto.Gen.Migration.run(["create_#{schema}", "--change", changes] ++ ecto_opts)
    else
      _ ->
        Mix.shell().info("Couldn't create migration")
    end
  end

  defp inferation_opts(opts) do
    i_opts = Keyword.take(opts, [:lines])
    NimbleCSV.define(RawlCSVParser, separator: Keyword.get(opts, :separator, ","), escape: "\"")

    Keyword.put(i_opts, :parser, RawlCSVParser)
  end

  defp column_defaults(%Rawl.Column{allow_nil?: false}), do: ", null: false"
  defp column_defaults(_), do: ""

  embed_template(:changes, """
      create table(:<%= @schema %>) do
  <%= for column <- @columns do %>      add :<%= String.downcase(column.name) %>, :<%= column.type %><%= column_defaults(column) %>
  <% end %>
      end
  """)
end
