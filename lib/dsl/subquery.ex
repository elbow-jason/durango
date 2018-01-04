defmodule Durango.Dsl.Subquery do

  alias Durango.Query
  alias Durango.Dsl

  def parse_query(%Query{} = q, subquery_ast) do
    subquery =
      %Durango.Query{
        bound_variables: q.bound_variables,
        local_variables: q.local_variables,
      }
      |> Dsl.parse_query(subquery_ast)

    %{ q | bound_variables: subquery.bound_variables }
    |> Query.append_tokens("(")
    |> Query.append_tokens(subquery.tokens)
    |> Query.append_tokens(")")
  end

end
