defmodule Durango.AQL.ReservedWord do


  @list ~w(
    aggregate
    all
    and
    any
    asc
    collect
    desc
    distinct
    false
    filter
    for
    graph
    in
    inbound
    insert
    into
    let
    limit
    none
    not
    null
    or
    outbound
    remove
    replace
    return
    shortest_path
    sort
    true
    update
    upsert
    with
  )a
  @set Enum.into(@list, MapSet.new)

  def is_reserved_word?(item) do
    item in @set
  end

  def words(), do: @list

  defmacro list_macro() do
    quote do
      ~w(
        aggregate
        all
        and
        any
        asc
        collect
        desc
        distinct
        false
        filter
        for
        graph
        in
        inbound
        insert
        into
        let
        limit
        none
        not
        null
        or
        outbound
        remove
        replace
        return
        shortest_path
        sort
        true
        update
        upsert
        with
      )a
    end
  end
end
