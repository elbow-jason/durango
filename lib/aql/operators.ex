defmodule Durango.AQL.Operators do
  @list [
    :==,       # equality
    :!=,       # inequality
    :<,        # less than
    :<=,       # less or equal
    :>,        # greater than
    :>=,       # greater or equal
    :IN,       # test if a value is contained in an array
    :NOT,      # IN test if a value is not contained in an array
    :LIKE,     # tests if a string value matches a pattern
    :"=~",     # tests if a string value matches a regular expression
    :"!=~",    # tests if a string value does not match a regular expression
  ]
  @set Enum.into(@list, MapSet.new)

  def is_operator?(thing) do
    thing in @set
  end

  def list() do
    @list
  end

  defmacro list_macro() do
    quote do
      [
        :==,
        :!=,
        :<,
        :<=,
        :>,
        :>=,
        :IN,
        :NOT,
        :LIKE,
        :"=~",
        :"!=~",
      ]
    end
  end
end
