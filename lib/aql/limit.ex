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
      iex> require Durango
      Durango
      iex> Durango.query([for: u, in: :users, limit: 5, return: u]) |> to_string
      "FOR u IN users LIMIT 5 RETURN u"

  """

  alias Durango.{
    Query,
    Dsl,
    Dsl.BoundVar,
  }

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      alias Durango.Dsl

      def parse_query(%Query{} = q, [{:limit, {offset, count}} | rest]) do
        q
        |> Query.append_tokens("LIMIT")
        |> Durango.AQL.Limit.append_args(offset, count)
        |> Dsl.parse_query(rest)
      end
      def parse_query(%Query{} = q, [{:limit, count} | rest ]) do
        q
        |> Query.append_tokens("LIMIT")
        |> Durango.AQL.Limit.append_args(count)
        |> Dsl.parse_query(rest)
      end
    end
  end



  @doc """

  """
  def append_args(%Query{} = q, num) when is_integer(num) do
    Query.append_tokens(q, to_string(num))
  end
  def append_args(%Query{} = q, %BoundVar{} = var) do
    Query.append_tokens(q, BoundVar.to_aql(var))
  end
  def append_args(%Query{} = q, {:^, _, [{name, _, nil}]} = quoted) when is_atom(name) do
    {bv, _params_map} = Durango.Dsl.BoundVar.from_quoted(quoted)
    q
    |> Query.put_bound_var(bv)
    |> Query.append_tokens("@" <> to_string(name))
  end

  def append_args(q, offset, count) do
    q
    |> append_args(offset)
    |> Query.append_tokens(",")
    |> append_args(count)
  end


end
