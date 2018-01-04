defmodule Durango.AQL.Remove do
  alias Durango.Query

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      alias Durango.Dsl
      
      def parse_query(%Query{} = q, [{:remove, {:in, _, [remove_expr, in_expr]}} | rest ]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.append_tokens("REMOVE")
        |> Dsl.parse_expr(remove_expr)
        |> Query.append_tokens("IN")
        |> Dsl.parse_expr(in_expr)
        |> Dsl.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:remove, remove_expr}, {:in, in_expr} | rest]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.append_tokens("REMOVE")
        |> Dsl.parse_expr(remove_expr)
        |> Query.append_tokens("IN")
        |> Dsl.parse_expr(in_expr)
        |> Dsl.parse_query(rest)
      end

    end
  end


end
