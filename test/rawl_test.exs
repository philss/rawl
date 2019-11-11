defmodule RawlTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Rawl.Column

  doctest Rawl

  describe "infer_type/1" do
    test "returns a tuple with type and data" do
      assert {:ok, :string} = Rawl.infer_type("potato")
      assert {:ok, :integer} = Rawl.infer_type("42")
      assert {:ok, :float} = Rawl.infer_type("12.83")
      assert {:ok, :boolean} = Rawl.infer_type("true")
      assert {:ok, :boolean} = Rawl.infer_type("false")
      assert {:ok, :date} = Rawl.infer_type("2019-10-10")
      assert {:ok, :empty} = Rawl.infer_type("")
    end

    property "detect numbers as integers" do
      check all(
              number <- integer(),
              number_str = to_string(number)
            ) do
        assert {:ok, :integer} = Rawl.infer_type(number_str)
      end
    end

    property "detect float strings as floats" do
      check all(
              number <- float(),
              number_str = to_string(number)
            ) do
        assert {:ok, :float} = Rawl.infer_type(number_str)
      end
    end

    property "detect text as strings" do
      check all(
              a <- string(:alphanumeric, min_length: 2),
              b <- string(:alphanumeric, min_length: 2),
              content = a <> b
            ) do
        assert {:ok, :string} = Rawl.infer_type(content)
      end
    end
  end

  describe "infer_csv_types!/2" do
    test "can infer the schema of a CSV file" do
      assert [
               %Column{
                 allow_nil?: false,
                 name: "name",
                 ocurrencies: %{string: 3},
                 type: :string
               },
               %Column{
                 allow_nil?: false,
                 name: "age",
                 ocurrencies: %{integer: 3},
                 type: :integer
               },
               %Column{
                 allow_nil?: false,
                 name: "weight",
                 ocurrencies: %{float: 3},
                 type: :float
               },
               %Column{
                 allow_nil?: true,
                 name: "from_it",
                 ocurrencies: %{boolean: 2, empty: 1},
                 type: :boolean
               },
               %Column{
                 allow_nil?: false,
                 name: "birth",
                 ocurrencies: %{date: 3},
                 type: :date
               }
             ] = Rawl.infer_csv_types!("./test/fixtures/sample.csv")
    end
  end
end
