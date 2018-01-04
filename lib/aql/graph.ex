defmodule Durango.AQL.Graph do

  defmacro inject_parser() do
    quote do
      alias Durango.Query

      def parse_query(%Query{} = q, [{:graph, graph_name} | rest]) when is_binary(graph_name) do
        q
        |> append_tokens(["GRAPH", inspect(graph_name)])
        |> parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:outbound, graph_node} | rest]) when is_binary(graph_node) do
        q
        |> append_tokens(["OUTBOUND", inspect(graph_node)])
        |> parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:inbound, graph_node} | rest]) when is_binary(graph_node) do
        q
        |> append_tokens(["INBOUND", inspect(graph_node)])
        |> parse_query(rest)
      end

    end
  end

end
