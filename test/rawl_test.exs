defmodule RawlTest do
  use ExUnit.Case
  use ExUnitProperties

  doctest Rawl

  describe "infer_type/1" do
    test "returns a tuple with type and data" do
      assert {:ok, :string} = Rawl.infer_type("potato")
      assert {:ok, :integer} = Rawl.infer_type("42")
      assert {:ok, :float} = Rawl.infer_type("12.83")
      assert {:ok, :bool} = Rawl.infer_type("true")
      assert {:ok, :bool} = Rawl.infer_type("false")
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
end
