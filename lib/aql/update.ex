defmodule Durango.AQL.Update do
  alias Durango.Query

  defmacro inject_parser() do
    quote do
      alias Durango.Query

      def parse_query(%Query{} = q, [{:update, update_expr}, {:with, with_expr}, {:in, in_expr} | rest ]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("UPDATE")
        |> Query.parse_expr(update_expr)
        |> Query.append_tokens("WITH")
        |> Query.parse_expr(with_expr)
        |> Query.append_tokens("IN")
        |> Query.parse_expr(in_expr)
        |> Query.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:update, {:in, _, [update_expr, in_expr]}} | rest ]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("UPDATE")
        |> Query.parse_expr(update_expr)
        |> Query.append_tokens("IN")
        |> Query.parse_expr(in_expr)
        |> Query.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:update, update_expr}, {:in, in_expr} | rest]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("UPDATE")
        |> Query.parse_expr(update_expr)
        |> Query.append_tokens("IN")
        |> Query.parse_expr(in_expr)
        |> Query.parse_query(rest)
      end

    end
  end


end
