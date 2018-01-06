defmodule Durango.Query do
  alias Durango.Query
  alias Durango.Dsl.{
    BoundVar,
  }

  defstruct [
    tokens:               [],
    local_variables:      [],
    bound_variables:      %{},
    collections:          [],
    last_reserved_word:   nil,
  ]

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

  def put_collection(%Query{} = q, _, {:.., _, _}) do
    q
  end
  def put_collection(%Query{} = q, label, {:__aliases__, _, parts}) do
    module = parts |> Module.concat
    if Durango.Document.is_document?(module) do
      name = module.__document__(:collection)
      put_collection(q, label, name)
    else
      put_collection(q, label, module)
    end
  end
  def put_collection(%Query{collections: collections} = q, label, module) when is_atom(label) and is_atom(module) do
    %{ q | collections: [ {label, module} | collections] }
  end
  def put_collection(%Query{} = q, labels, module) when is_list(labels) and is_atom(module) do
    Enum.reduce(labels, q, fn l, q_acc -> put_collection(q_acc, l, module) end)
  end

  def ensure_in_locals!(%Query{local_variables: locals}, item) do
    unless name = Durango.Dsl.Helpers.base_name(item) in locals do
      msg = """
      "Durango.Query encountered an invalid object name. Got #{inspect name}. Valid objects are #{inspect locals}."
      "Durango.Query parsing error
      Encountered an invalid object name. Got #{inspect name}. Valid objects are #{inspect locals}."
      """
      raise CompileError, description: msg
    end
  end

  def to_json(%Query{} = q) do
    %{
      query: to_string(q),
      bindVars: bound_vars_json(q),
    }
  end

  def to_aql(%Query{} = q) do
    to_string(q)
  end

  def bound_vars_json(%Query{bound_variables: bound_vars}) do
    bound_vars
    |> Map.values
    |> Enum.map(fn bv -> {BoundVar.json_key(bv), BoundVar.json_value(bv)} end)
    |> Enum.into(%{})
  end

end

defimpl String.Chars, for: Durango.Query do
  def to_string(%Durango.Query{tokens: tokens}) do
    tokens
    |> Enum.join(" ")
  end
end
