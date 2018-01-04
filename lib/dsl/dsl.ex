defmodule Durango.Dsl do
  alias Durango.Query
  alias Durango.Dsl.{
    BoundVar,
    DotAccess,
    Object,
    Function,
    # Subquery,
  }
  alias Durango.AQL.{
    ReservedWord,
    Operators,
    Limit,
    Sort,
    Options,
    Remove,
    Update,
    Replace,
    Insert,
    For,
    Graph,
    Return,
    Filter,
    Let,
    With,
    Upsert,
    Collect,
  }
  require ReservedWord
  require Operators
  require DotAccess
  require BoundVar
  require Object
  require Limit
  require Function
  require Sort
  require Options
  require Remove
  require Update
  require Replace
  require Insert
  require For
  require Graph
  require Return
  require Filter
  require Let
  require With
  require Upsert
  require Collect

  BoundVar.inject_parser()
  DotAccess.inject_parser()
  Limit.inject_parser()
  Object.inject_parser()
  Function.inject_parser()
  Sort.inject_parser()
  Remove.inject_parser()
  Options.inject_parser()
  Update.inject_parser()
  Replace.inject_parser()
  Insert.inject_parser()
  For.inject_parser()
  Filter.inject_parser()
  Graph.inject_parser()
  Return.inject_parser()
  Let.inject_parser()
  With.inject_parser()
  Upsert.inject_parser()
  Collect.inject_parser()

  def preprocess_ast(ast) do
    {ast, bound} = BoundVar.from_quoted(ast)
    ast = DotAccess.from_quoted(ast)
    {ast, bound}
  end


  def parse_query(query, []) do
    # this function must come after all parsers.
    # this function is a finalizer for compilation.
    %{ query | tokens: query.tokens |> Enum.join(" ") |> List.wrap }
  end

  def parse_expr(%Query{} = q, {:__aliases__, _, [:OLD]}) do
    if :OLD in q.local_variables do
      q
      |> Query.append_tokens("OLD")
    else
      msg = [
        "Durango.Query.query parsing error -",
        "OLD variable is only in scope with using",
        "UPDATE, REPLACE, or REMOVE.",
      ]
      |> Enum.join(" ")
      raise CompileError, description: msg
    end
  end
  def parse_expr(%Query{} = q, {:__aliases__, _, [:NEW]}) do
    if :NEW in q.local_variables do
      q
      |> Query.append_tokens("NEW")
    else
      msg = [
        "Durango.Query.query parsing error -",
        "NEW variable is only in scope with using",
        "UPDATE, REPLACE, or INSERT.",
      ]
      |> Enum.join(" ")
      raise CompileError, description: msg
    end
  end

  def parse_expr(%Query{} = q, {:subquery, _, [ast]}) when is_list(ast) do
    Durango.Dsl.Subquery.parse_query(q, ast)
  end
  def parse_expr(%Query{} = q, :in) do
    Query.append_tokens(q, "IN")
  end
  def parse_expr(%Query{} = q, :and) do
    Query.append_tokens(q, "AND")
  end
  def parse_expr(%Query{} = q, {key, expr}) when is_atom(key) do
    q
    |> Query.append_tokens([to_string(key)])
    |> parse_expr(expr)
  end
  def parse_expr(%Query{} = q, bool) when is_boolean(bool) do
    q
    |> Query.append_tokens(to_string(bool))
  end
  def parse_expr(%Query{} = q, {:inline, _, [%DotAccess{} = dot, sub_query]}) do
    # https://docs.arangodb.com/3.3/AQL/Advanced/ArrayOperators.html#inline-expressions
    token = DotAccess.to_aql(dot)
    q
    |> Query.put_local_var(:CURRENT)
    |> Query.append_tokens(token<>"[*")
    |> parse_query(sub_query)
    |> Query.append_tokens("]")
  end
  def parse_expr(%Query{} = q, atom) when is_atom(atom) do
    q
    |> Query.append_tokens(to_string(atom))
  end

  @reserved_words ReservedWord.list_macro()
  @operators Operators.list_macro()
  @op_or_reserved @reserved_words ++ @operators

  def parse_expr(%Query{} = q, {comp, _, [left, right]}) when comp in @op_or_reserved do
    q
    |> parse_expr(left)
    |> parse_expr(comp)
    |> parse_expr(right)
  end

  def parse_expr(%Query{} = q, {:if, _, [conditional, [{:do, do_expr}, {:else, else_expr}]]}) do
    q
    |> Dsl.parse_expr(conditional)
    |> Query.append_tokens("?")
    |> Dsl.parse_expr(do_expr)
    |> Query.append_tokens(":")
    |> Dsl.parse_expr(else_expr)
  end
  def parse_expr(%Query{} = q, {:=, _, [left, right]}) do
    local_variable = Dsl.Helpers.extract_labels(left)
    q
    |> Query.put_local_var(local_variable)
    |> Dsl.parse_expr(left)
    |> Query.append_tokens("=")
    |> Dsl.parse_expr(right)
  end
  def parse_expr(%Query{} = q, {{:., _, [{base, _, nil}, attr]}, _, []}) do
    Query.ensure_in_locals!(q, base)
    Query.append_tokens(q, Dsl.Helpers.stringify(base) <> "." <> Dsl.Helpers.stringify(attr))
  end
  # @operators Operators.list_macro()
  def parse_expr(%Query{} = q, op) when op in Operators.list_macro() do
    Query.append_tokens(q, to_string(op))
  end
  def parse_expr(%Query{} = q, item) when is_binary(item) when is_number(item) do
    Query.append_tokens(q, inspect(item))
  end
  def parse_expr(%Query{} = q, {item, _, nil}) do
    Query.append_tokens(q, Dsl.Helpers.stringify(item))
  end
  def parse_expr(%Query{} = q, items) when is_list(items) do
    Dsl.parse_query(q, items)
  end

  def reduce_assignments(%Query{} = q, expressions, sep) when is_list(expressions) and is_binary(sep) do
    {%Query{local_variables: updated_local_vars, bound_variables: updated_bound_vars }, all_tokens} =
      expressions
      |> Enum.reduce({q, []} , fn expr, {q_acc, tokens} ->
        item_query =
          %Query{
            local_variables: q_acc.local_variables,
            bound_variables: q_acc.bound_variables,
          }
          |> Dsl.parse_expr(expr)

        { item_query, tokens ++ [Enum.join(item_query.tokens, " ")] }
    end)
    joined_tokens = Enum.join(all_tokens, sep)
    %{ q |
      bound_variables: Map.merge(q.bound_variables, updated_bound_vars),
      local_variables: q.local_variables ++ updated_local_vars,
    }
    |> Query.append_tokens(joined_tokens)
  end

end
