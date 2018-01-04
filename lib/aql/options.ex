defmodule Durango.AQL.Options do

  defmacro inject_parser() do
    quote do

      alias Durango.Query
      alias Durango.Dsl

      def parse_query(%Query{} = q, [{:options, options_expr} | rest]) do
        q
        |> Query.append_tokens("OPTIONS")
        |> Dsl.parse_expr(options_expr)
        |> Dsl.parse_query(rest)
      end

    end
  end

end
