defmodule Durango.Document do

  defmacro  __using__(_) do
    quote do
      require Durango.Document
      import Durango.Document
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.put_attribute(__MODULE__, :fields, {:_id, nil})
      Module.put_attribute(__MODULE__, :fields, {:_key, nil})
      Module.put_attribute(__MODULE__, :fields, {:_rev, nil})
    end
  end

  defmacro document(collection, block) when is_atom(collection) do
    quote do
      def __document__(:is_document?) do
        true
      end
      def __document__(:collection) do
        unquote(collection)
      end
      unquote(block)
      def bef() do
        :bef
      end
      @before_compile Durango.Document
    end
  end

  defmacro field(name, type \\ :any, options \\ []) do
    quote do
      Module.put_attribute(__MODULE__, :fields, {unquote(name),  unquote(options) |> Enum.into(%{}) |> Map.put(:type, unquote(type)) })
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __document__(:fields) do
        @fields
      end

      defstruct Keyword.keys(@fields)

    end
  end

  def is_document?(%module{}) do
    is_document?(module)
  end
  def is_document?(module) when is_atom(module) do
    try do
      module.__document__(:is_document?)
    rescue
      _ -> false
    end
  end

end
