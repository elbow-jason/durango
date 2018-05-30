defmodule Durango.Dsl.Helpers do
  alias Durango.{
    Dsl.DotAccess,
    Dsl,
    Query,
  }

  def extract_labels(labels) when is_list(labels) do
    labels
    |> Enum.map(&base_name/1)
  end
  def extract_labels({:{}, _, args}) when is_list(args) do
    extract_labels(args)
  end
  def extract_labels(labels) do
    labels
    |> base_name
    |> List.wrap
  end

  def stringify(items, sep) when is_list(items) and is_binary(sep) do
    items
    |> Enum.map(fn item -> stringify(item) end)
    |> Enum.join(sep)
  end

  def stringify({:.., _, [low, high]}) when is_integer(low) and is_integer(high) do
    stringify(low)<>".."<>stringify(high)
  end
  def stringify({:{}, _, args}) do
    stringify(args, ", ")
  end
  def stringify(n) when is_number(n) do
    to_string(n)
  end
  def stringify(item) when is_atom(item) do
    if Durango.Document.is_document?(item) do
      item.__document__(:collection) |> to_string
    else
      to_string(item)
    end
  end
  def stringify({:__aliases__, _, _} = item) do
    item
    |> var_name
    |> stringify
  end
  def stringify({{:., _, [{base, _, nil}, attr]}, _, []}) do
    to_string(base) <> "." <> to_string(attr)
  end
  def stringify({item, _, nil}) when is_atom(item) do
    to_string(item)
  end
  def stringify({item, _, args} = ast) when is_atom(item) and is_list(args) do
    args_count = length(args)
    case Durango.Dsl.Function.Names.functions() |> Keyword.get(item) do
      start..fin when args_count >= start and args_count <= fin ->
        Durango.Dsl.parse_expr(%Query{}, ast) |> to_string
      other ->
        raise "Unrecognized function #{item} with arity #{args_count} found: #{inspect other}"
    end
  end

  defp render_function(name, [coll | rest]) do
    func_name =
      name
      |> to_string
      |> String.upcase
    coll = if Durango.Document.is_document?(coll) do
      coll.__document__(:collection)
    else
      coll
    end
    rest_args = Enum.map(rest, &inspect/1)
    func_name <> "(" <> Enum.join([coll | rest_args], ", ") <> ")"
  end
  defp render_function(name, []) do
    name
    |> to_string
    |> String.upcase
    |> Kernel.<>("()")
  end

  def var_name({:__aliases__, _, parts}) do
    Module.concat(parts)
  end
  def var_name({name, _, _}) when is_atom(name) do
    name
  end
  def var_name(name) when is_atom(name) do
    name
  end
  def var_name({{:., _, [{base, _, nil}, attr]}, _, []}) do
    to_string(base) <> "." <> to_string(attr)
  end

  def base_name({{:., _, [{base, _, nil}, _attr]}, _, []}) do
    base
  end
  def base_name(atom) when is_atom(atom) do
    atom
  end
  def base_name({name, _, _}) when is_atom(name) do
    name
  end
  def base_name(%DotAccess{attrs: [{:base, base} | _]}) do
    base
  end


end
