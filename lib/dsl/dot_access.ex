defmodule Durango.Dsl.DotAccess do
  alias Durango.Dsl.DotAccess

  use Durango.Dsl.Quoter

  defstruct [
    attrs: [],
  ]

  def get_base(%DotAccess{attrs: [ base | _ ]}) do
    base
  end
  def get_base(_) do
    nil
  end

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
  def put_attrs(%DotAccess{} = dot, {type, _} = attr) when type in [:bracket, :dot, :base] do
    %{ dot | attrs: dot.attrs ++ [attr]}
  end

  @doc """
  
  """
  def to_aql(%DotAccess{attrs: attrs}) do
    attrs
    |> Enum.map(fn
      {:dot, item} ->
        "." <> to_string(item)
      {:bracket, item} when is_integer(item) ->
        "["<>to_string(item)<>"]"
      {:bracket, item} when is_atom(item) when is_binary(item) ->
        "["<>Durango.Dsl.String.to_aql(item)<>"]"
      {:base, item} -> to_string(item)
    end)
    |> Enum.join("")
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
    from_quoted(%DotAccess{}, ast)
  end
  def from_quoted(%DotAccess{} = dot, {{:., _, [Access, :get]}, _, [rest | [ key | []]]}) when is_integer(key) when is_atom(key) when is_binary(key) do
    dot
    |> put_attrs({:bracket, key})
    |> from_quoted(rest)
  end
  def from_quoted(%DotAccess{} = dot, {{:., _, [rest | [attrs | []]]}, _, []}) do
    dot
    |> put_attrs({:dot, attrs})
    |> from_quoted(rest)
  end
  def from_quoted(%DotAccess{} = dot, {base, _meta, ctx}) when is_atom(base) and is_atom(ctx) do
    attrs =
      dot
      |> put_attrs({:base, base})
      |> Map.get(:attrs)
      |> Enum.reverse
    %{ dot | attrs: attrs }
  end

end
