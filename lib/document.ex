defmodule Durango.Document do

  defmacro  __using__(_) do
    quote do
      require Durango.Document
      import Durango.Document
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
