defmodule Durango.Dsl.Quoter do

  defmacro __using__(_) do
    quote do
      @before_compile Durango.Dsl.Quoter
    end
  end


  @doc false
  defmacro __before_compile__(_env) do
    quote do

      # def from_quoted({:%{}, meta, args}) when is_list(args) do
      #   {:%{}, meta, args |> from_quoted}
      # end
      def from_quoted({label, meta, args}) when is_list(args) and is_atom(label) do
        {label, meta, args |> from_quoted}
      end
      def from_quoted({{_, _, _} = label, meta, args}) do
        {from_quoted(label), meta, from_quoted(args)}
      end
      def from_quoted(list) when is_list(list) do
        list
        |> Enum.map(&from_quoted/1)
      end
      def from_quoted({key, value}) do
        {from_quoted(key), from_quoted(value)}
      end
      def from_quoted(anything_else) do
        anything_else
      end

    end
  end

  def module_to_list(module) do
    module
    |> Module.split
    |> Enum.map(&String.to_existing_atom/1)
  end

  def to_quoted(%module{} = structure) do
    {:%, [], [
      {:__aliases__, [alias: false], module_to_list(module) },
      structure |> Map.from_struct() |> to_quoted,
    ]}
  end

  def to_quoted(thing) when is_list(thing) do
    thing
    |> Enum.map(&to_quoted/1)
  end
  def to_quoted(thing) when is_map(thing) do
    {:%{}, [], thing |> Enum.map(&to_quoted/1) |> Enum.into([]) }
  end
  def to_quoted(thing) when is_atom(thing) when is_binary(thing) when is_number(thing) do
    thing
  end
  def to_quoted({key, value}) do
    {to_quoted(key), to_quoted(value)}
  end
  def to_quoted({atom, meta, nil} = already_quoted) when is_atom(atom) and is_list(meta) do
    # this pattern is for variables
    already_quoted
  end
  def to_quoted({atom, meta, args}) when is_atom(atom) and is_list(meta) and is_list(args) do
    {atom, meta, to_quoted(args) }
  end
  def to_quoted({{:., meta1, args1}, meta2, args2}) when is_list(args2) do
    {{:., meta1, to_quoted(args1)}, meta2, to_quoted(args2)}
  end

end
