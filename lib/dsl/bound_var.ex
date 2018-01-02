defmodule Durango.Dsl.BoundVar do
  alias Durango.Dsl.BoundVar

  defstruct [
    key:          nil,
    value:        nil,
    validations:  [],
  ]

  def new(key, value, validations \\ []) when (is_atom(key) or is_binary(key)) and is_list(validations) do
    %BoundVar{
      key: key,
      value: value,
      validations: validations,
    }
  end

  def put_validation(%BoundVar{} = bv, validation) do
    %{ bv | validations: [validation | bv.validations]}
  end


  def validate(%BoundVar{validations: validations} = bv) do
    validations
    |> Enum.map(fn validation -> validate(bv, validation) end)
    |> Enum.filter(fn
      :ok -> nil
      _ -> true
    end)
    |> case do
      [] -> :ok
      errors ->
      {:error, errors |> Enum.map(fn {:error, reason} -> reason end) }
    end
  end

  def validate(%BoundVar{value: value}, :int_required) when is_integer(value) do
    :ok
  end

  def validate(bv, validation) do
    {:error, "Durango bound variable #{inspect bv.key} failed validation #{inspect validation} for value #{inspect bv.value}"}
  end

  defmacro inject_parser() do
    quote do
      alias Durango.Dsl.BoundVar
      alias Durango.Query
      def parse_query(%Query{} = q, {:^, _, [{bound_key, _, _} = bound_value]}) when is_atom(bound_key) do
        bv = BoundVar.new(bound_key, bound_value)
        parse_query(q, bv)
      end
      def parse_query(%Query{} = q, %BoundVar{} = bv) do
        token = BoundVar.to_aql(bv)
        q
        |> Query.put_bound_var(bv)
        |> Query.append_tokens(token)
      end

      def parse_expr(%Query{} = q, {:^, _, [dot = %Durango.Dsl.DotAccess{ast: bound_value}]}) do
        bound_key =
          dot
          |> Durango.Dsl.DotAccess.to_aql
          |> String.replace(~r/[\.\[\]]/, "_")
          |> String.replace(~r/_$/, "")
        bv = BoundVar.new(bound_key, bound_value)
        token = BoundVar.to_aql(bv)
        q
        |> Query.put_bound_var(bv)
        |> Query.append_tokens(token)
      end
      def parse_expr(%Query{} = q, %BoundVar{} = bv) do
        token = BoundVar.to_aql(bv)
        q
        |> Query.put_bound_var(bv)
        |> Query.append_tokens(token)
      end
    end
  end


  def from_quoted(ast) do
    reduce_bound_vars(ast, %{})
  end

  def reduce_bound_vars(items, bound_vars) when is_list(items) do
    items
    |> Enum.reduce({[], bound_vars}, fn item, {items_acc, bound_acc} ->
        {item, bound_acc} = reduce_bound_vars(item, bound_acc)
        {items_acc ++ [item], bound_acc}
    end)
  end
  def reduce_bound_vars({:^, _, [{bound_key, _, _} = bound_value]}, bound_vars) when is_atom(bound_key) do
    bv = BoundVar.new(bound_key, bound_value)
    {bv, Map.put(bound_vars, bv.key, bv)}
  end
  def reduce_bound_vars({atom, meta, nil} = item, bound_vars) when is_atom(atom) and is_list(meta) do
    {item, bound_vars}
  end
  def reduce_bound_vars({atom, meta, args}, bound_vars) when is_atom(atom) and is_list(meta) and is_list(args) do
    # IO.inspect({atom, args}, label: :reduce_bound_vars)
    {args, bound_vars} = reduce_bound_vars(args, bound_vars)
    {{atom, meta, args}, bound_vars}
  end
  def reduce_bound_vars({{atom, meta1, args1}, meta2, args2}, bound_vars) do
    {args1, bound_vars} = reduce_bound_vars(args1, bound_vars)
    {args2, bound_vars} = reduce_bound_vars(args2, bound_vars)
    {{{atom, meta1, args1}, meta2, args2}, bound_vars}
  end
  def reduce_bound_vars({key, value}, bound_vars) do
    {new_value, new_bound} = reduce_bound_vars(value, bound_vars)
    {{key, new_value}, new_bound}
  end
  def reduce_bound_vars(item, bound_vars) do
    {item, bound_vars}
  end



  def to_aql(%BoundVar{key: key}) do
    "@" <> to_string(key)
  end

end
