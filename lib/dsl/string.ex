defmodule Durango.Dsl.String do

  def to_aql(item) when is_binary(item) do
    "\""<>item<>"\""
  end
  def to_aql(item) when is_atom(item) do
    item
    |> to_string
    |> to_aql
  end

end
