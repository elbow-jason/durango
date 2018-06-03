defmodule Durango.AQL.LimitTest do
  use ExUnit.Case
  alias Durango.{
    Query,
    AQL.Limit,
    Dsl.BoundVar,
  }
  doctest Limit

  describe "append_args/2" do
    test "works for integers" do
      assert Limit.append_args(%Query{}, 5) == %Query{tokens: ["5"]}
    end

    test "works for bound_vars" do
      assert Limit.append_args(%Query{}, %BoundVar{key: :thing}) == %Query{tokens: ["@thing"]}
    end
  end

  describe "append_args/3" do
    test "works for offset and count integers" do
      assert Limit.append_args(%Query{}, 100, 10) == %Query{tokens: ["100", ",", "10"]}
    end
  end

end
