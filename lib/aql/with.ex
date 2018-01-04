defmodule Durango.AQL.With do

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      def parse_query(%Query{tokens: []} = q, [{:with, collections} | rest ]) when is_list(collections) do
        collections_token = Query.stringify(collections, ", ")
        q
        |> Query.append_tokens("WITH")
        |> Query.append_tokens(collections_token)
      end

      def parse_query(%Query{tokens: tokens} = q, [{:with, _} | _ ]) when length(tokens) > 0 do
        msg = """

        Durango.Query parsing error -
          WITH is only allowed at the beginning of a query that requires traveral locking or after UPDATE or REPLACE.

        """
        raise CompileError, description: msg
      end
      def parse_query(%Query{tokens: []}, [{:with, _} | _ ]) do
        msg = """

        Durango.Query parsing error - WITH at the beginning of a query expects a list of collections.

        """
        raise CompileError, description: msg
      end
    end
  end

end
