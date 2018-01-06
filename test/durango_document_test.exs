defmodule DurangoDocumentTest do
  use ExUnit.Case
  doctest Durango.Document
  require Durango
  alias DurangoExample.{Person, Repo}

  test "query can handle document models" do
    %person_collection{} = person = %Person{
      name: "Jason",
      age: 30,
    }
    q = Durango.query([
      insert: ^person, into: ^person_collection,
    ])
    assert q.bound_variables == %{
      person:             %Durango.Dsl.BoundVar{key: :person, keytype: nil, value: %DurangoExample.Person{age: 30, name: "Jason"}},
      person_collection:  %Durango.Dsl.BoundVar{key: :person_collection, keytype: :collection, value: DurangoExample.Person},
    }
    assert to_string(q) == "INSERT @person INTO @@person_collection"
    assert Durango.Query.bound_vars_json(q) == %{
      "@person_collection"  => "persons",
      "person"              => %{age: 30, name: "Jason"}}
  end

end
