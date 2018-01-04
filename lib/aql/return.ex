defmodule Durango.AQL.Return do

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      
      def parse_query(%Query{} = q, [{:return, expr} | rest ]) do
        q
        |> append_tokens("RETURN")
        |> parse_expr(expr)
        |> parse_query(rest)
      end

    end
  end
end
