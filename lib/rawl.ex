defmodule Rawl do
  import Norm

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
               bool: spec(&bool?/1),
               integer: spec(&integer?/1),
               float: spec(&float?/1),
               string: spec(is_binary())
             )
           ) do
      {:ok, type}
    end
  end

  def infer_type(data), do: {:error, "val \"#{inspect(data)}\" cannot be parsed"}

  defp integer?(num), do: String.match?(num, ~r/^[+\-]?(?:0|[1-9]\d*)$/)

  defp float?(num), do: String.match?(num, ~r/^[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?$/)

  defp bool?(bool), do: String.match?(bool, ~r/^(true|false)$/)
end
