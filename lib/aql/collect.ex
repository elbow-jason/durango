defmodule Durango.AQL.Collect do
  @moduledoc """

  Forms:

    COLLECT variableName = expression options
    COLLECT variableName = expression INTO groupsVariable options
    COLLECT variableName = expression INTO groupsVariable = projectionExpression options
    COLLECT variableName = expression INTO groupsVariable KEEP keepVariable options
    COLLECT variableName = expression WITH COUNT INTO countVariable options
    COLLECT variableName = expression AGGREGATE variableName = aggregateExpression options
    COLLECT AGGREGATE variableName = aggregateExpression options
    COLLECT WITH COUNT INTO countVariable options
  """
  defmacro inject_parser() do
    quote do

      alias Durango.Query
      alias Durango.Dsl
      def parse_query(%Query{} = q, [{:collect, coll}, {:into, into_expr}, {:keep, keepers} | rest ])  do
        keepers =
          keepers
          |> List.wrap
          |> List.flatten
          |> Dsl.Helpers.extract_labels
          |> Enum.join(", ")
        coll =
          coll
          |> List.wrap
          |> List.flatten
        q
        |> Query.append_tokens("COLLECT")
        |> Dsl.reduce_assignments(coll, ", ")
        |> Query.append_tokens("INTO")
        |> Dsl.parse_expr(into_expr)
        |> Query.append_tokens("KEEP")
        |> Query.append_tokens(keepers)
        |> Dsl.parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:collect, coll}, {:into, into_expr} | rest ]) do
        coll =
          coll
          |> List.wrap
          |> List.flatten
        q
        |> Query.append_tokens("COLLECT")
        |> Dsl.reduce_assignments(coll, ", ")
        |> Query.append_tokens("INTO")
        |> Dsl.parse_expr(into_expr)
        |> Dsl.parse_query(rest)
      end

      def parse_query(%Query{} = q, [{:collect, {:=, _, _} = assignment}, {:into, into_expr} | rest ]) do
        q
        |> Query.append_tokens("COLLECT")
        |> Dsl.reduce_assignments([assignment], ", ")
        |> Query.append_tokens("INTO")
        |> Dsl.parse_expr(into_expr)
        |> Dsl.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:collect, {:=, _, _} = assignment} | rest ]) do
        q
        |> Query.append_tokens("COLLECT")
        |> Dsl.reduce_assignments([assignment], ", ")
        |> Dsl.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:collect_with_count_into, label} | rest ]) do
        labels = Dsl.Helpers.extract_labels(label)
        q
        |> Query.append_tokens("COLLECT WITH COUNT INTO")
        |> Query.append_tokens(labels)
        |> Dsl.parse_query(rest)
      end
    end
  end


end
