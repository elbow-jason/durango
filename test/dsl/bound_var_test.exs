defmodule DurangoDslBoundVarTest do
  use ExUnit.Case
  doctest Durango.Dsl.BoundVar
  require Durango.Dsl.BoundVar
  alias Durango.Dsl.BoundVar

  test "new/2 works" do
    assert BoundVar.new(:name, "Jason") == %BoundVar{key: :name, value: "Jason"}
  end

  test "new/3 works" do
    assert BoundVar.new(:name, "Jason", [:int_required]) == %BoundVar{
      key: :name,
      value: "Jason",
      validations: [:int_required],
    }
  end

  test "put_validation/2 works" do
    assert BoundVar.new(:name, "WaduHek") |> BoundVar.put_validation(:int_required) == %BoundVar{
      key: :name,
      value: "WaduHek",
      validations: [:int_required],
    }
  end

  test "validate/1 errors on invalid value" do
    bv = BoundVar.new(:name, "Jason", [:int_required])
    assert BoundVar.validate(bv) == {:error, ["Durango bound variable :name failed validation :int_required for value \"Jason\""]}
  end

  test "validate for :int_required works" do
    assert BoundVar.new(:count, 10, [:int_required]) |> BoundVar.validate == :ok
  end

  #
  # test "parse/1 macro works on pinned values" do
  #   count = 1
  #   assert BoundVar.parse(^count) == %BoundVar{key: :count, value: 1}
  # end
end
