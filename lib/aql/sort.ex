defmodule Durango.AQL.Sort do


  defmacro inject_parser() do
    quote do
      alias Durango.Query

      def parse_query(%Query{} = q, [{:sort, {by_items, modifier}} | rest]) do
        items_token = Durango.AQL.Sort.render_items(by_items)
        modifier_token = Durango.AQL.Sort.render_modifier(modifier)
        sort_token = [
            items_token,
            modifier_token,
          ]
          |> Enum.join(" ")
          |> String.trim
        q
        |> Durango.Query.append_tokens(["SORT", sort_token])
        |> parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:sort, by_items} | rest]) do
        items_token = Durango.AQL.Sort.render_items(by_items)
        q
        |> Durango.Query.append_tokens(["SORT", items_token])
        |> parse_query(rest)
      end

    end
  end

  def render_modifier(order) when order in [:desc, :DESC, "DESC", "desc"] do
    "DESC"
  end
  def render_modifier(order) when order in [:asc, :ASC, "ASC", "asc"] do
    "ASC"
  end

  def render_items(items) when is_list(items) do
    items
    |> Enum.map(&render_items/1)
    |> Enum.join(", ")
  end
  def render_items(%module{} = item) do
    module.to_aql(item)
  end

end
