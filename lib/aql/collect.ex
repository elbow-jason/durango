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

      def parse_query(%Query{} = q, [{:collect, list}, {:into, into_expr} | rest ]) when is_list(list) do
        q
        |> Query.append_tokens("COLLECT")
        |> Dsl.reduce_assignments(list, ", ")
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
    end
  end


end
