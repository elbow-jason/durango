defmodule Durango.Query do
  alias Durango.Query
  alias Durango.Dsl.{
    BoundVar,
    DotAccess,
    Object,
    Function,
  }
  alias Durango.AQL.{
    ReservedWord,
    Operators,
    Limit,
  }
  require ReservedWord
  require Operators
  require DotAccess
  require BoundVar
  require Object
  require Limit
  require Function

  defstruct [
    tokens:               [],
    local_variables:      [],
    bound_variables:      %{},
    collections:          [],
    last_reserved_word:   nil,
  ]

  def preprocess_ast(ast) do
    {ast, bound} = BoundVar.from_quoted(ast)
    ast = DotAccess.from_quoted(ast)
    {ast, bound}
  end

  defmacro query(query, ast) do
    {ast, bound_vars} = preprocess_ast(ast)
    bound_vars = Map.merge(query.bound_variables, bound_vars)
    query = %{ query | bound_variables: bound_vars }
    parsed = parse_query(query, ast)
    quoted = Durango.Dsl.Quoter.to_quoted(parsed)
    quote do
      unquote(quoted)
    end
  end

  defmacro query(ast) do
    {ast, bound_vars} = preprocess_ast(ast)
    parsed = parse_query(%Query{bound_variables: bound_vars}, ast)
    quoted = Durango.Dsl.Quoter.to_quoted(parsed)
    quote do
      unquote(quoted)
    end
  end


  def put_local_var(%Query{local_variables: locals} = q, local) when is_atom(local) do
    %{ q | local_variables: [local | locals] |> Enum.uniq }
  end
  def put_local_var(%Query{} = q, others) when is_list(others) do
    Enum.reduce(others, q, fn item, q_acc ->
      put_local_var(q_acc, item)
    end)
  end

  def put_bound_var(%Query{bound_variables: prev} = q, %BoundVar{} = bv) do
    %{ q | bound_variables: Map.put(prev, bv.key, bv) }
  end

  def is_bound_var?(%Query{bound_variables: bound_vars}, name) do
    Map.has_key?(bound_vars, name)
  end

  def append_tokens(%Query{tokens: tokens} = q, more_tokens) when is_list(more_tokens) do
    %{ q | tokens: tokens ++ more_tokens }
  end
  def append_tokens(%Query{} = q, token) do
    append_tokens(q, [token])
  end

  defp put_collection(%Query{} = q, _, {:.., _, _}) do
    q
  end
  defp put_collection(%Query{collections: collections} = q, label, module) when is_atom(label) and is_atom(module) do
    %{ q | collections: [ {label, module} | collections] }
  end
  defp put_collection(%Query{} = q, labels, module) when is_list(labels) and is_atom(module) do
    Enum.reduce(labels, q, fn l, q_acc -> put_collection(q_acc, l, module) end)
  end

  BoundVar.inject_parser()
  DotAccess.inject_parser()
  Limit.inject_parser()
  Object.inject_parser()
  Function.inject_parser()

  def parse_query(%Query{} = q, [{:return, expr} | rest ]) do
    q
    |> append_tokens("RETURN")
    |> parse_expr(expr)
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:filter, expr} | rest ]) do
    q
    |> append_tokens("FILTER")
    |> parse_expr(expr)
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:for, {:in, _, [labels, collection]}} | rest ]) do
    labels = extract_labels(labels)
    q
    |> append_tokens(["FOR", stringify(labels, ", "), "IN", stringify(collection)])
    |> put_local_var(labels)
    |> put_collection(labels, collection)
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:for, labels}, {:in_inbound, {prev_label, attr}} | rest ]) do
    ensure_in_locals!(q, prev_label)
    labels = extract_labels(labels)
    q
    |> put_local_var(labels)
    |> append_tokens(["FOR", stringify(labels, ", "), "IN", "INBOUND", stringify(prev_label), stringify(attr)])
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:graph, graph_name} | rest]) when is_binary(graph_name) do
    q
    |> append_tokens(["GRAPH", inspect(graph_name)])
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:outbound, graph_node} | rest]) when is_binary(graph_node) do
    q
    |> append_tokens(["OUTBOUND", inspect(graph_node)])
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:for, labels}, {:in_outbound, {prev_label, attr}} | rest ]) do
    ensure_in_locals!(q, prev_label)
    labels = extract_labels(labels)
    q
    |> put_local_var(labels)
    |> append_tokens(["FOR", stringify(labels, ", "), "IN", "OUTBOUND", stringify(prev_label), stringify(attr)])
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:for, labels}, {:in, collection} | rest ]) do
    labels = extract_labels(labels)
    q
    |> append_tokens(["FOR", stringify(labels, ", "), "IN", stringify(collection)])
    |> put_local_var(labels)
    |> put_collection(labels, collection)
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:insert, obj} | rest]) do
    q
    |> append_tokens(["INSERT"])
    |> parse_expr(obj)
    |> parse_query(rest)
  end
  def parse_query(%Query{} = q, [{:into, collection} | rest]) do
    q
    |> append_tokens(["INTO", stringify(collection)])
    |> parse_query(rest)
  end
  def parse_query(query, []) do
    query
  end

  defp ensure_in_locals!(%Query{local_variables: locals}, item) do
    unless name = base_name(item) in locals do
      raise CompileError, description: "Durango.Query encountered an invalid object name. Got #{inspect name}. Valid objects are #{inspect locals}."
    end
  end

  # def parse_expr(%Query{} = q, {:%{}, _, fields}) do
  #   q = put_token()
  #   q = Enum.reduce(fields, q, fn item, q_acc -> parse_expr(q_acc, item) end)
  #   IO.inspect(reduced, label: :reduced_query_map)
  # end
  def parse_expr(%Query{} = q, :in) do
    q
    |> append_tokens("IN")
  end
  def parse_expr(%Query{} = q, :and) do
    q
    |> append_tokens("AND")
  end
  def parse_expr(%Query{} = q, {key, expr}) when is_atom(key) do
    q
    |> append_tokens([to_string(key)])
    |> parse_expr(expr)
  end
  def parse_expr(%Query{} = q, bool) when is_boolean(bool) do
    q
    |> append_tokens(to_string(bool))
  end
  def parse_expr(%Query{} = q, {:inline, _, [%DotAccess{} = dot, sub_query]}) do
    # https://docs.arangodb.com/3.3/AQL/Advanced/ArrayOperators.html#inline-expressions
    token = DotAccess.to_aql(dot)
    q
    |> put_local_var(:CURRENT)
    |> append_tokens(token<>"[*")
    |> parse_query(sub_query)
    |> append_tokens("]")
  end


  @reserved_words ReservedWord.list_macro()
  @operators Operators.list_macro()
  @op_or_reserved @reserved_words ++ @operators
  def parse_expr(%Query{} = q, {comp, _, [left, right]}) when comp in @op_or_reserved do
    # IO.inspect({comp, left, right}, label: :comparator?)
    q
    |> parse_expr(left)
    |> parse_expr(comp)
    |> parse_expr(right)
  end

  def parse_expr(%Query{} = q, {{:., _, [{base, _, nil}, attr]}, _, []}) do
    ensure_in_locals!(q, base)
    append_tokens(q, stringify(base) <> "." <> stringify(attr))
  end
  # @operators Operators.list_macro()
  def parse_expr(%Query{} = q, op) when op in Operators.list_macro() do
    append_tokens(q, to_string(op))
  end
  def parse_expr(%Query{} = q, item) when is_binary(item) when is_number(item) do
    append_tokens(q, inspect(item))
  end
  def parse_expr(%Query{} = q, {item, _, nil}) do
    append_tokens(q, stringify(item))
  end
  def parse_expr(%Query{} = q, items) when is_list(items) do
    parse_query(q, items)
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

  def var_name({:__aliases__, _, parts}) do
    parts
    |> Module.concat
    |> case do
      string when is_binary(string) ->
        String.to_existing_atom(string)
      atom when is_atom(atom) ->
        atom
    end
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

  def to_json(%Query{} = q) do
    %{
      query: to_string(q),
      boundVars: q.bound_variables |> Enum.map(fn {_, %BoundVar{} = bv} -> {bv.key, bv.value} end) |> Enum.into(%{}),
    }
  end

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

  def to_aql(%Query{} = q) do
    to_string(q)
  end

end

defimpl String.Chars, for: Durango.Query do
  def to_string(%Durango.Query{tokens: tokens}) do
    tokens
    |> Enum.join(" ")
  end
end
