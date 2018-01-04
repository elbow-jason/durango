defmodule Durango.AQL.Filter do

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      alias Durango.Dsl
      def parse_query(%Query{} = q, [{:filter, expr} | rest ]) do
        q
        |> Query.append_tokens("FILTER")
        |> Dsl.parse_expr(expr)
        |> Dsl.parse_query(rest)
      end

    end
  end

end
