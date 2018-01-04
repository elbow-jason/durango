defmodule Durango.AQL.Filter do

  defmacro inject_parser() do
    quote do
      alias Durango.Query

      def parse_query(%Query{} = q, [{:filter, expr} | rest ]) do
        q
        |> append_tokens("FILTER")
        |> parse_expr(expr)
        |> parse_query(rest)
      end

    end
  end

end
