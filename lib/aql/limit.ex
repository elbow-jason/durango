defmodule Durango.AQL.Limit do
  @moduledoc """
  General Forms:

  ```
  LIMIT count
  ```
  ```
  LIMIT offset, count
  ```

  AQL Example Usage:

  ```
  FOR u IN users
    LIMIT 5
    RETURN u
  ```

  ```
  FOR u IN users
    SORT u.firstName, u.lastName, u.id DESC
    LIMIT 2, 5
    RETURN u
  ```

  Durango Query Usage:
      iex> require Durango.Query
      Durango.Query
      iex> [for: u, in: :users, limit: 5, return: u] |> Durango.Query.query() |> to_string
      "FOR u IN users LIMIT 5 RETURN u"

  """

  alias Durango.Query
  alias Durango.Dsl.BoundVar

  defmacro inject_parser() do
    quote do
      def parse_query(%Query{} = q, [{:limit, {offset, count}} | rest]) do
        limit_token = Durango.AQL.Limit.render_args(offset, count)
        q
        |> Durango.Query.append_tokens(["LIMIT", limit_token])
        |> parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:limit, count} | rest ]) do
        # IO.inspect(count, label: :limit_count)
        limit_token = Durango.AQL.Limit.render_args(count)
        q
        |> Durango.Query.append_tokens(["LIMIT", limit_token])
        |> parse_query(rest)
      end
    end
  end



  @doc """

    iex> Durango.AQL.Limit.render_args(5)
    "5"

    iex> Durango.AQL.Limit.render_args(%Durango.Dsl.BoundVar{key: :thing})
    "@thing"

    iex> Durango.AQL.Limit.render_args(100, 10)
    "100, 10"

  """
  def render_args(num) when is_integer(num) do
    to_string(num)
  end
  def render_args(%BoundVar{} = var) do
    BoundVar.to_aql(var)
  end
  def render_args(offset, count) do
    render_args(offset) <> ", " <> render_args(count)
  end

end
