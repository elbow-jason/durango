defmodule Durango.AQL.Update do
  alias Durango.Query

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      alias Durango.Dsl

      @in_keys [:in, :into]

      def parse_query(%Query{} = q, [{:update, update_expr}, {:with, with_expr}, {in_key, in_expr} | rest ]) when in_key in @in_keys do
        in_token = case in_key do
          :in   -> "IN"
          :into -> "INTO"
        end
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("UPDATE")
        |> Dsl.parse_expr(update_expr)
        |> Query.append_tokens("WITH")
        |> Dsl.parse_expr(with_expr)
        |> Query.append_tokens(in_token)
        |> Dsl.parse_expr(in_expr)
        |> Dsl.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:update, update_expr}, {:with, with_expr} | rest ]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("UPDATE")
        |> Dsl.parse_expr(update_expr)
        |> Query.append_tokens("WITH")
        |> Dsl.parse_expr(with_expr)
        |> Dsl.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:update, {:in, _, [update_expr, in_expr]}} | rest ]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("UPDATE")
        |> Dsl.parse_expr(update_expr)
        |> Query.append_tokens("IN")
        |> Dsl.parse_expr(in_expr)
        |> Dsl.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:update, update_expr}, {:in, in_expr} | rest]) do
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("UPDATE")
        |> Dsl.parse_expr(update_expr)
        |> Query.append_tokens("IN")
        |> Dsl.parse_expr(in_expr)
        |> Dsl.parse_query(rest)
      end

    end
  end


end
