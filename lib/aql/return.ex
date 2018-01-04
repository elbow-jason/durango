defmodule Durango.AQL.Return do

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      alias Durango.Dsl

      def parse_query(%Query{} = q, [{:return, expr} | rest ]) do
        q
        |> Query.append_tokens("RETURN")
        |> Dsl.parse_expr(expr)
        |> Dsl.parse_query(rest)
      end

    end
  end
end
