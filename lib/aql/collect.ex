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
      def parse_query(%Query{} = q, [{:collect, {:=, _, [left, right]}}, {:into, into_expr} | rest ]) do
        labels = extract_labels(left)
        label_tokens = Query.stringify(labels, ", ")
        q
        |> Query.put_local_var(labels)
        |> Query.append_tokens("COLLECT")
        |> Query.append_tokens(label_tokens)
        |> Query.append_tokens("=")
        |> Query.parse_expr(right)
        |> Query.append_tokens("INTO")
        |> Query.parse_expr(into_expr)
        |> parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:collect, {:=, _, [left, right]}} | rest ]) do
        labels = extract_labels(left)
        label_tokens = Enum.map(labels, &to_string/1)
        q
        |> Query.put_local_var(labels)
        |> Query.append_tokens("COLLECT")
        |> Query.append_tokens(label_tokens)
        |> Query.append_tokens("=")
        |> parse_expr(right)
        |> parse_query(rest)
      end
    end
  end


end
