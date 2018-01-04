defmodule Durango do
  @moduledoc """
  Documentation for Durango.
  """
  alias Durango.Query
  alias Durango.Dsl
  alias Durango.Dsl.{Quoter}

  defmacro query(%Query{} = query, ast) do
    {ast, bound_vars} = Dsl.preprocess_ast(ast)
    bound_vars = Map.merge(query.bound_variables, bound_vars)
    query = %{ query | bound_variables: bound_vars }
    parsed = Dsl.parse_query(query, ast)
    quoted = Quoter.to_quoted(parsed)
    quote do
      unquote(quoted)
    end
  end

  defmacro query(ast) do
    {ast, bound_vars} = Dsl.preprocess_ast(ast)
    parsed = Dsl.parse_query(%Query{bound_variables: bound_vars}, ast)
    quoted = Quoter.to_quoted(parsed)
    quote do
      unquote(quoted)
    end
  end



end
