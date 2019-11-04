defmodule Rawl do
  import Norm

  defmodule Report do
    @moduledoc false
    defstruct headers: [],
              columns: []
  end

  defmodule Column do
    defstruct name: "", ocurrencies: %{}, type: nil, allow_nil?: false

    @typedoc """
    A representation of a Column that was analyzed, with its name, type and occurrencies.
    """

    @type t :: %Column{
            name: String.t(),
            ocurrencies: Map.t(),
            type: Atom.t(),
            allow_nil?: boolean()
          }
  end

  @spec infer_type(String.t()) :: {:ok, Atom.t()} | {:error, String.t()}
  @doc """
  Infer the type of the content for a given string by checking regexes.
  It falls back to "string" when there is no match.

  ## Examples

      iex> Rawl.infer_type("potato")
      {:ok, :string}
      iex> Rawl.infer_type("42")
      {:ok, :integer}

  """
  def infer_type(data) when is_binary(data) do
    with {:ok, {type, _data}} <-
           conform(
             data,
             alt(
               empty: spec(is_binary() and fn str -> str == "" end),
               boolean: spec(&bool?/1),
               integer: spec(&integer?/1),
               float: spec(&float?/1),
               date: spec(&date?/1),
               string: spec(is_binary())
             )
           ) do
      {:ok, type}
    end
  end

  def infer_type(data), do: {:error, "val \"#{inspect(data)}\" cannot be parsed"}

  @spec infer_csv_types!(String.t(), parser: Atom.t(), lines: Integer.t()) :: [Rawl.Column.t()]
  @doc """
  Infer the type of columns from a CSV file based on it's content lines.
  You can configure the number of lines that will be analyzed using the option `lines`.
  You also can configure the parser with `parser` option.
  """
  def infer_csv_types!(csv_file_path, opts \\ []) do
    parser = Keyword.get(opts, :parser, NimbleCSV.RFC4180)
    lines_to_analyze = Keyword.get(opts, :lines, 100)

    headers =
      csv_file_path
      |> File.stream!()
      |> parser.parse_stream(skip_headers: false)
      |> Enum.take(1)
      |> Enum.at(0)

    lines =
      csv_file_path
      |> File.stream!()
      |> parser.parse_stream(skip_headers: true)
      |> Enum.take(lines_to_analyze)

    result =
      Enum.reduce(lines, Enum.map(headers, fn _ -> %Column{} end), fn line, columns ->
        types =
          Enum.map(line, fn column ->
            case infer_type(column) do
              {:ok, type} -> type
              _ -> :string
            end
          end)

        types
        |> Enum.zip(columns)
        |> Enum.map(fn {type, column} ->
          total = Map.get(column.ocurrencies, type, 0)
          allow_nil? = column.allow_nil? || match?(^type, :empty)

          ocurrencies = Map.put(column.ocurrencies, type, total + 1)

          %{column | ocurrencies: ocurrencies, allow_nil?: allow_nil?}
        end)
      end)

    headers
    |> Enum.zip(result)
    |> Enum.map(fn {header, column} ->
      set =
        column.ocurrencies
        |> Map.keys()
        |> MapSet.new()
        |> MapSet.delete(:empty)

      type =
        cond do
          MapSet.equal?(set, MapSet.new([:float, :integer])) ->
            :float

          MapSet.equal?(set, MapSet.new([:boolean])) ->
            :boolean

          MapSet.size(set) == 1 ->
            [first | _] = MapSet.to_list(set)
            first

          true ->
            :string
        end

      %{column | type: type, name: header}
    end)
  end

  defp integer?(num), do: String.match?(num, ~r/^[+\-]?(?:0|[1-9]\d*)$/)

  defp float?(num), do: String.match?(num, ~r/^[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?$/)

  defp bool?(boolean), do: String.match?(boolean, ~r/^(true|false)$/)

  defp date?(date_str),
    do: String.match?(date_str, ~r/^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12][0-9]|3[01])$/)
end
