defmodule Durango.AQL.Let do

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      def parse_query(%Query{} = q, [{:let, {:=, _, [left, right]}} | rest2]) do
        q
        |> append_tokens("LET")
        |> append_tokens(extract_labels(left))
        |> append_tokens("=")
        |> parse_expr(right)
        |> parse_query(rest2)
      end
    end
  end

end
