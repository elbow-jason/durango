defmodule Durango.AQL.Upsert do

  defmacro inject_parser() do
    quote do

      alias Durango.Query
      alias Durango.Dsl

      @in_keys [:in, :into]
      @change_keys [:update, :replace]

      def parse_query(%Query{} = q, [{:upsert, upsert_expr}, {:insert, insert_expr}, {change_key, change_expr}, {in_key, in_expr} | rest ]) when in_key in @in_keys and change_key in @change_keys do
        in_token = case in_key do
          :in   -> "IN"
          :into -> "INTO"
        end
        change_token = case change_key do
          :update   -> "UPDATE"
          :replace  -> "REPLACE"
        end
        q
        |> Query.put_local_var(:OLD)
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("UPSERT")
        |> Dsl.parse_expr(upsert_expr)
        |> Query.append_tokens("INSERT")
        |> Dsl.parse_expr(insert_expr)
        |> Query.append_tokens(change_token)
        |> Dsl.parse_expr(change_expr)
        |> Query.append_tokens(in_token)
        |> Dsl.parse_collection_name(in_expr)
        |> Dsl.parse_query(rest)
      end
    end
  end

end
