defmodule Durango.AQL.For do

  defmacro inject_parser() do
    quote do

      alias Durango.Query
      def parse_query(%Query{} = q, [{:for, labels}, {:in_inbound, {prev_label, attr}} | rest ]) do
        Query.ensure_in_locals!(q, prev_label)
        labels = Query.extract_labels(labels)
        q
        |> Query.put_local_var(labels)
        |> Query.append_tokens([
          "FOR",
          Query.stringify(labels, ", "),
          "IN",
          "INBOUND",
          Query.stringify(prev_label),
          Query.stringify(attr),
        ])
        |> parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:for, labels}, {:in, collection} | rest ]) do
        labels = Query.extract_labels(labels)
        q
        |> Query.append_tokens([
          "FOR",
          Query.stringify(labels, ", "),
          "IN",
          Query.stringify(collection),
        ])
        |> Query.put_local_var(labels)
        |> Query.put_collection(labels, collection)
        |> Query.parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:for, labels}, {:in_outbound, {prev_label, attr}} | rest ]) do
        Query.ensure_in_locals!(q, prev_label)
        labels = Query.extract_labels(labels)
        q
        |> Query.put_local_var(labels)
        |> Query.append_tokens([
          "FOR",
          Query.stringify(labels, ", "),
          "IN",
          "OUTBOUND",
          Query.stringify(prev_label),
          Query.stringify(attr),
        ])
        |> Query.parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:for, {:in, _, [labels, collection]}} | rest ]) do
        labels = Query.extract_labels(labels)
        q
        |> Query.append_tokens([
          "FOR",
          Query.stringify(labels, ", "),
          "IN",
          Query.stringify(collection),
        ])
        |> Query.put_local_var(labels)
        |> Query.put_collection(labels, collection)
        |> Query.parse_query(rest)
      end

    end
  end

end
