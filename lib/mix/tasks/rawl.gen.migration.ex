defmodule Mix.Tasks.Rawl.Gen.Migration do
  use Mix.Task

  @shortdoc "Generates a new migration for the CSV file"

  @switches [
    name: :string
  ]

  @impl true
  def run(args) do
    case OptionParser.parse!(args, switches: @switches) do
      {opts, [file_path]} ->
        Mix.shell().info("Creating a migration for file #{file_path}")
        name = Keyword.get(opts, :name, "default_name")
        # TODO: make this use a template
        changes ="""
        # Here are the changes
        """
        # TODO: make this pass the options to the migration
        Mix.Tasks.Ecto.Gen.Migration.run(["add_#{name}_table", "--change", changes])

      {_, _} ->
        Mix.shell().info("Couldn't create migration")
    end
  end
end
