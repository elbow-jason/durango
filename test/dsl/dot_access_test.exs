defmodule DurangoDslDotAccessTest do
  use ExUnit.Case
  doctest Durango.Dsl.DotAccess
  alias Durango.Dsl.DotAccess

  test "from_quoted can parse a multi dot accessed AST" do
    ast = quote do u.details.name end
    expected = %Durango.Dsl.DotAccess{attrs: [{:base, :u}, {:dot, :details}, {:dot, :name}]}
    assert DotAccess.from_quoted(ast) == expected
  end

  test "from_quoted can parse any AST 1" do
    ast = quote do %{name: u.age} end
    expected = {:%{}, [], [name: %Durango.Dsl.DotAccess{attrs:  [{:base, :u}, {:dot, :age}]}]}
    assert DotAccess.from_quoted(ast) == expected
  end

  test "from_quoted can parse any AST 2" do
    ast = quote do {u.age} end
    expected = {:{}, [], [%Durango.Dsl.DotAccess{attrs:  [{:base, :u}, {:dot, :age}]}]}
    assert DotAccess.from_quoted(ast) == expected
  end


  test "from_quoted can parse any AST 3" do
    ast = quote do [for: u, in: :users, return: u.age] end
    expected = [
      for: {:u, [], DurangoDslDotAccessTest},
      in: :users,
      return: %Durango.Dsl.DotAccess{attrs: [{:base, :u}, {:dot, :age}]},
    ]
    assert DotAccess.from_quoted(ast) == expected
  end

  test "to_aql renders base, dot, and brack access correctly" do
    dot = %Durango.Dsl.DotAccess{attrs: [base: :u, dot: :details, bracket: :name]}
    assert Durango.Dsl.DotAccess.to_aql(dot) == "u.details[\"name\"]"
  end

end
