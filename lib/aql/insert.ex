defmodule Durango.AQL.Insert do

  defmacro inject_parser() do
    quote do

      alias Durango.Query
      alias Durango.Dsl
      alias Durango.Dsl.BoundVar

      @in_keys [:into, :in]

      def parse_query(%Query{} = q, [{:insert, insert_expr}, {in_key, in_expr} | rest]) when in_key in @in_keys do
        in_token = case in_key do
          :into -> "INTO"
          :in -> "IN"
        end
        q
        |> Query.put_local_var(:NEW)
        |> Query.append_tokens("INSERT")
        |> Dsl.parse_expr(insert_expr)
        |> Query.append_tokens(in_token)
        |> Dsl.parse_collection_name(in_expr)
        |> Dsl.parse_query(rest)
      end



    end
  end

end
