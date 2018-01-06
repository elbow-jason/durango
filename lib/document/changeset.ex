defmodule Durango.Document.Changeset do
  alias Durango.Document.Changeset

  defstruct [
    module:   nil,
    params:   nil,
    changes:  nil,
    document: nil,
    errors:   [],
  ]

  def get_value(%Changeset{changes: changes, document: doc}, key) do
    cond do
      Map.has_key?(changes, key) -> Map.get(changes, key)
      true -> Map.get(doc, key)
    end
  end

  def put_error(%Changeset{} = cs, field, validator, reason) do
    %{ cs | errors: [ {field, validator, reason} | cs.errors ]}
  end

  def cast(%module{} = doc, params, allowed) when is_map(params) and is_list(allowed) do
    %Changeset{
      module:   module,
      params:   params,
      changes:  params |> GenUtil.Map.to_atom_keys |> Map.take(allowed),
      document: doc
    }
  end

  def validate(%Changeset{} = cs, fields, validator) when is_list(fields) and is_function(validator, 2) do
    Enum.reduce(fields, cs, validator)
  end
  def validate(%Changeset{} = cs, field, validator) when is_atom(field) do
    validate(cs, [field], validator)
  end

  def validate_required(%Changeset{} = cs, fields) when is_list(fields) do
    validate(cs, fields, fn field_name, cs_acc ->
      case get_value(cs_acc, field_name) do
        nil ->
          put_error(cs_acc, field_name, :validate_required, "is required")
        "" ->
          put_error(cs_acc, field_name, :validate_required, "is required")
        _ ->
          cs_acc
      end
    end)
  end

  def validate_document_types(%Changeset{} = cs) do
    validate_document_types(cs, cs.document |> Map.drop([:__struct__]) |> Map.keys)
  end
  def validate_document_types(%Changeset{} = cs, fields) when is_list(fields) do
    validate(cs, fields, fn field_name, cs_acc ->
      type = Durango.Document.Type.type(cs.module, field_name)
      value = Durango.Document.Changeset.get_value(cs, field_name)
      if Durango.Document.Type.is_type?(value, type) do
        cs_acc
      else
        put_error(cs_acc, field_name, :validate_document_types, "is incorrect type")
      end
    end)
  end

end
