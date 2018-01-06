defmodule Durango.Document.Type do

  def type(%module{}, name) do
    type(module, name)
  end
  def type(module, name) when is_atom(module) and is_atom(name) do
    module.__document__(:fields)
    |> Keyword.get(name, %{})
    |> Map.get(:type)
  end

  def get_type(%module{}) do
    module
  end
  def get_type(x) when is_integer(x) do
    :integer
  end
  def get_type(x) when is_float(x) do
    :float
  end
  def get_type(x) when is_binary(x) do
    :string
  end
  def get_type(x) when is_boolean(x) do
    :boolean
  end
  def get_type(x) when is_list(x) do
    x
    |> Enum.map(&get_type/1)
    |> Enum.uniq
    |> case do
      [:invalid] ->
        :invalid
      [type] ->
        {:array, type}
      _ ->
        :invalid
    end
  end
  def get_type(x) when is_map(x) do
    :object
  end
  def get_type(_) do
    :invalid
  end

  def is_type?(%_{} = model, name, type) when is_atom(name) and is_atom(type) do
    model
    |> Map.get(name)
    |> is_type?(type)
  end

  def is_type?(value, type) do
    is_type?({value, type})
  end
  def is_type?({value, type}) do
    case {value, type} do
      {_, :any}                         -> true
      {v, :string}  when is_binary(v)   -> true
      {v, :integer} when is_integer(v)  -> true
      {v, :float}   when is_float(v)    -> true
      {v, :boolean} when is_boolean(v)  -> true
      {v, {:array, subtype}}            -> array_is_type?(v, subtype)
      {%module{} = v, :object}          -> object_is_type?(v, module)
      {v, :object}  when is_map(v)      -> true
      {v, module}  when is_atom(module) -> object_is_type?(v, module)
      _ -> false
    end
  end

  defp array_is_type?(array, subtype) when is_list(array) do
    Enum.all?(array, fn sub_v -> is_type?(sub_v, subtype) end)
  end
  defp array_is_type?(_, _) do
    false
  end

  defp object_is_type?(object, module) when is_map(object) do
    if Durango.Document.is_document?(module) do
      object
      |> Map.from_struct()
      |> Enum.all?(fn {name, value} ->
        is_type?({value, type(module, name)})
      end)
    else
      false
    end
  end
  defp object_is_type?(_, _) do
    false
  end

end
