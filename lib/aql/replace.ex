defmodule Durango.AQL.Replace do
  alias Durango.Query

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      @in_keys [:in, :into]
      def parse_query(%Query{} = q, [{:replace, update_expr}, {:with, with_expr}, {in_key, in_expr} | rest ]) when in_key in @in_keys do
        in_token = case in_key do
          :in -> "IN"
          :into -> "INTO"
        end
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("REPLACE")
        |> Query.parse_expr(update_expr)
        |> Query.append_tokens("WITH")
        |> Query.parse_expr(with_expr)
        |> Query.append_tokens(in_token)
        |> Query.parse_expr(in_expr)
        |> Query.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:replace, update_expr}, {:with, with_expr} | rest ]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("REPLACE")
        |> Query.parse_expr(update_expr)
        |> Query.append_tokens("WITH")
        |> Query.parse_expr(with_expr)
        |> Query.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:replace, {:in, _, [update_expr, in_expr]}} | rest ]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("REPLACE")
        |> Query.parse_expr(update_expr)
        |> Query.append_tokens("IN")
        |> Query.parse_expr(in_expr)
        |> Query.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:replace, update_expr}, {:in, in_expr} | rest]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("REPLACE")
        |> Query.parse_expr(update_expr)
        |> Query.append_tokens("IN")
        |> Query.parse_expr(in_expr)
        |> Query.parse_query(rest)
      end

    end
  end


end
