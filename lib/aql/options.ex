defmodule Durango.AQL.Options do

  defmacro inject_parser() do
    quote do
      alias Durango.Query

      def parse_query(%Query{} = q, [{:options, options_expr} | rest]) do
        q
        |> Query.append_tokens("OPTIONS")
        |> Query.parse_expr(options_expr)
        |> Query.parse_query(rest)
      end

    end
  end

end
