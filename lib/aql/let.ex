defmodule Durango.AQL.Let do

  defmacro inject_parser() do
    quote do
      alias Durango.{
        Query,
        Dsl,
      }

      def parse_query(%Query{} = q, [{:let, {:=, _, [left, right]}} | rest ]) do
        left_labels = Dsl.Helpers.extract_labels(left)
        q
        |> Query.append_tokens("LET")
        |> Query.append_tokens(left_labels)
        |> Query.append_tokens("=")
        |> Dsl.parse_expr(right)
        |> Dsl.parse_query(rest)
      end
    end
  end

end
