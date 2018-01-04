defmodule Durango.Dsl.Object do
  alias Durango.Dsl.Object
  use Durango.Dsl.Quoter
  alias Durango.Query
  alias Durango.Dsl

  defstruct [
    fields: []
  ]

  def put_field(%Object{fields: fields} = obj, key, value) do
    %{ obj | fields: [{key, value} | fields ]}
  end

  def from_quoted({:%{}, _, fields}) do
    from_quoted(%Object{}, fields)
  end
  def from_quoted(%Object{} = obj, fields) when is_list(fields) do
    fields
    |> Enum.reduce(obj, fn {k, v}, obj_acc ->
      {ast, _bound_vars} = Durango.Dsl.preprocess_ast(v)
      put_field(obj_acc, k, ast)
    end)
  end

  defmacro inject_parser() do
    quote do
      alias Durango.Query
      alias Durango.Dsl.Object

      def parse_expr(%Query{} = q, {:%{}, _, fields}) when is_list(fields) do
        fields_query = Enum.map(fields, fn {key, value} ->
          value_query = Dsl.parse_expr(%Query{local_variables: q.local_variables}, value)
          {key, value_query}
        end)
        obj = %Object{fields: fields_query}
        body = Object.render_body(obj)
        q
        |> Query.append_tokens("{ " <> body <> " }")
      end
    end
  end

  def render_body(%Object{fields: fields}) do
    fields
    |> Enum.map(fn field -> render_field(field) end)
    |> Enum.join(", ")
  end

  def render_field({key, %module{} = value}) do
    to_string(key)<>": "<>module.to_aql(value)
  end
  def render_field({key, value}) when is_atom(key) do
    to_string(key)<>": "<>value
  end

end
