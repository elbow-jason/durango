defmodule Durango.AQL.For do

  defmacro inject_parser() do
    quote do

      alias Durango.Query
      alias Durango.Dsl

      def parse_query(%Query{} = q, [{:for, labels}, {:in_inbound, {prev_label, attr}} | rest ]) do
        Query.ensure_in_locals!(q, prev_label)
        labels = Dsl.Helpers.extract_labels(labels)
        q
        |> Query.put_local_var(labels)
        |> Query.append_tokens([
          "FOR",
          Dsl.Helpers.stringify(labels, ", "),
          "IN",
          "INBOUND",
          Dsl.Helpers.stringify(prev_label),
          Dsl.Helpers.stringify(attr),
        ])
        |> parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:for, labels}, {:in, collection} | rest ]) do
        labels = Dsl.Helpers.extract_labels(labels)
        q
        |> Query.append_tokens([
          "FOR",
          Dsl.Helpers.stringify(labels, ", "),
          "IN",
          Dsl.Helpers.stringify(collection),
        ])
        |> Query.put_local_var(labels)
        |> Query.put_collection(labels, collection)
        |> Dsl.parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:for, labels}, {:in_outbound, {prev_label, attr}} | rest ]) do
        Query.ensure_in_locals!(q, prev_label)
        labels = Dsl.Helpers.extract_labels(labels)
        q
        |> Query.put_local_var(labels)
        |> Query.append_tokens([
          "FOR",
          Dsl.Helpers.stringify(labels, ", "),
          "IN",
          "OUTBOUND",
          Dsl.Helpers.stringify(prev_label),
          Dsl.Helpers.stringify(attr),
        ])
        |> Dsl.parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:for, {:in, _, [labels, collection]}} | rest ]) do
        labels = Dsl.Helpers.extract_labels(labels)
        q
        |> Query.append_tokens([
          "FOR",
          Dsl.Helpers.stringify(labels, ", "),
          "IN",
          Dsl.Helpers.stringify(collection),
        ])
        |> Query.put_local_var(labels)
        |> Query.put_collection(labels, collection)
        |> Dsl.parse_query(rest)
      end

    end
  end

end
