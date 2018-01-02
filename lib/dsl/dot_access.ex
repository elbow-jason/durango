defmodule Durango.Dsl.DotAccess do
  alias Durango.Dsl.{DotAccess, BoundVar}
  use Durango.Dsl.Quoter

  defstruct [
    attrs: [],
    ast: nil,
    modifier: nil,
  ]

  def get_base(%DotAccess{attrs: [ base | _ ]}) do
    base
  end
  def get_base(_) do
    nil
  end

  @modifiers [:ALL, :ANY, :NONE]
  def put_modifier(%DotAccess{modifier: nil} = dot, modifier) when modifier in @modifiers do
    %{ dot | modifier: modifier }
  end
  def put_modifier(%DotAccess{} = dot, _) do
    dot
  end


  @types [:bracket, :dot, :base, :bound_var]
  @doc """
    iex> alias Durango.Dsl.DotAccess
    Durango.Dsl.DotAccess
    iex> %DotAccess{} |> DotAccess.put_attrs({:dot, :details}) |> DotAccess.put_attrs({:dot, :name})
    %Durango.Dsl.DotAccess{attrs: [dot: :details, dot: :name]}

    iex> %Durango.Dsl.DotAccess{} |> Durango.Dsl.DotAccess.put_attrs({:bracket, :details})
    %Durango.Dsl.DotAccess{attrs: [bracket: :details]}

    iex> %Durango.Dsl.DotAccess{} |> Durango.Dsl.DotAccess.put_attrs({:bracket, "details"})
    %Durango.Dsl.DotAccess{attrs: [bracket: "details"]}
  """
  def put_attrs(%DotAccess{} = dot, {type, _} = attr) when type in @types do
    %{ dot | attrs: dot.attrs ++ [attr]}
  end

  @doc """

  """
  def to_aql(%DotAccess{attrs: attrs, modifier: modifier}) do
    extra =
      case modifier do
        nil -> ""
        other -> " " <> to_string(other)
      end
    attrs
    |> Enum.map(fn
      {:dot, item} ->
        "." <> to_string(item)
      {:bracket, item} when is_integer(item) ->
        item
        |> to_string
        |> wrap_brackets
      {:bound_var, %BoundVar{} = bv} ->
        bv
        |> BoundVar.to_aql
        |> wrap_brackets
      {:bracket, item} when item in @modifiers ->
        wrap_brackets("*")
      {:bracket, item} when is_atom(item) when is_binary(item) ->
        item
        |> Durango.Dsl.String.to_aql()
        |> wrap_brackets
      {:base, item} -> to_string(item)
    end)
    |> Enum.join("")
    |> Kernel.<>(extra)
  end

  def wrap_brackets(item) when is_binary(item) do
    "["<>item<>"]"
  end

  defmacro inject_parser() do
    quote do
      def parse_query(%Durango.Query{} = q, {{:., _, [_, attr]}, _, rest} = ast) when is_atom(attr) do
        dot = %Durango.Dsl.DotAccess{} = Durango.Dsl.DotAccess.from_quoted(ast)
        token = Durango.Dsl.DotAccess.to_aql(dot)
        q
        |> Durango.Query.append_tokens(token)
        |> Durango.Query.parse_query(rest)
      end

      def parse_expr(%Durango.Query{} = q, {{:., _, [_, attr]}, _, rest} = ast) when is_atom(attr) do
        dot = %Durango.Dsl.DotAccess{} = Durango.Dsl.DotAccess.from_quoted(ast)
        token = Durango.Dsl.DotAccess.to_aql(dot)
        q
        |> Durango.Query.append_tokens(token)
        |> Durango.Query.parse_query(rest)
      end

      def parse_expr(%Durango.Query{} = q, %DotAccess{} = dot) do
        token = Durango.Dsl.DotAccess.to_aql(dot)
        q
        |> Durango.Query.append_tokens(token)
      end
    end
  end

  def from_quoted({{:., _, [_ | rest ]}, _, []} = ast) when length(rest) > 0 do
    from_quoted(%DotAccess{ast: ast}, ast)
  end
  def from_quoted(%DotAccess{} = dot, {{:., _, [Access, :get]}, _, [rest, key]}) when is_integer(key) when is_atom(key) when is_binary(key) do
    dot
    |> put_attrs({:bracket, key})
    |> put_modifier(key)
    |> from_quoted(rest)
  end
  def from_quoted(%DotAccess{} = dot, {{:., _, [Access, :get]}, _, [rest, other]}) do
    dot
    |> from_quoted(other)
    |> from_quoted(rest)
  end
  def from_quoted(%DotAccess{} = dot, {{:., _, [Access, :get]}, _, %BoundVar{} = bv}) do
    dot
    |> put_attrs({:bound_var, bv})
  end
  def from_quoted(%DotAccess{} = dot, {{:., _, [rest1, attr]}, _, rest2}) do
    dot
    # |> put_attrs({:dot, attr})
    |> from_quoted(attr)
    |> from_quoted(rest1)
    |> from_quoted(rest2)
  end
  def from_quoted(%DotAccess{} = dot, []) do
    dot
  end
  def from_quoted(%DotAccess{} = dot, key) when is_atom(key) do
    dot
    |> put_attrs({:base, key})
  end
  def from_quoted(%DotAccess{} = dot, %BoundVar{} = bv) do
    dot
    |> put_attrs({:bound_var, bv})
  end
  def from_quoted(%DotAccess{} = dot, {base, _meta, ctx}) when is_atom(base) and is_atom(ctx) do
    attrs =
      dot
      |> put_attrs({:base, base})
      |> Map.get(:attrs)
      |> Enum.reverse
    %{ dot | attrs: attrs }
  end
  def from_quoted(%DotAccess{} = dot,  {:__aliases__, _, [base]}) when is_atom(base) do
    attrs =
      dot
      |> put_attrs({:base, base})
      |> Map.get(:attrs)
      |> Enum.reverse
    %{ dot | attrs: attrs }
  end

end
