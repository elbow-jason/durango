defmodule Durango.Dsl.Function do
  @moduledoc """
  Listed at https://docs.arangodb.com/3.3/AQL/Functions/

  This module parses and renders functions.
  """

  def validate!({_name, low..high}, args) when length(args) >= low and length(args) <= high do
    nil
  end
  def validate!({name, count}, args) when is_integer(count) do
    validate!({name, count..count}, args)
  end
  def validate!({name, count..count}, args) do
    msg = "Durango.Function error - function #{inspect name} requires #{count} arguments. Got #{length(args)} arguments."
    raise CompileError, description: msg
  end
  def validate!({name, low..high}, args) do
    msg = "Durango.Function error - function #{inspect name} requires between #{low} and #{high} arguments. Got #{length(args)} arguments."
    raise CompileError, description: msg
  end

  def suffix(index, limit) when index >= limit do
    ""
  end
  def suffix(_, _) do
    ","
  end

  def render_func_name(func_name) when is_atom(func_name) do
    func_name
    |> to_string
    |> String.upcase
  end

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      alias Durango.Dsl.Function
      alias Durango.Dsl

      @function_names Function.Names.names_list()
      @functions      Function.Names.functions()

      def parse_expr(%Query{} = q, {func_name, _, args}) when func_name in @function_names do
        arity = Keyword.fetch!(@functions, func_name)
        Function.validate!({func_name, arity}, args)
        args_query =
          Enum.reduce(args, %Query{bound_variables: q.bound_variables}, fn arg, q_acc ->
            Dsl.parse_expr(q_acc, arg)
          end)
        func_token =
          [
            Function.render_func_name(func_name),
            "(",
            Enum.join(args_query.tokens, ", "),
            ")",
          ]
          |> Enum.join("")
        q
        |> Map.put(:bound_variables, args_query.bound_variables)
        |> Query.append_tokens(func_token)
      end
    end
  end

end
