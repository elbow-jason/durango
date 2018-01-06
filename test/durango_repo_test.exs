defmodule DurangoRepoTest do
  use ExUnit.Case
  doctest Durango.Repo
  require Durango

  alias DurangoExample.{Repo, Person}
  setup do
    DurangoExample.Repo.start_link(nil)
    :ok
  end

  test "execute will execute a valid query" do
    q = Durango.query([
      return: count(:persons),
    ])
    assert {:ok, %{"result" => [count]}} = Repo.execute(q)
    assert is_integer(count) == true
    assert count >= 0
  end

  test "execute will return error response for invalid query" do
    q = Durango.query([
      for: p in :something_that_does_not_exist,
      return: count(p),
    ])
    assert {:error, _} = Repo.execute(q)
  end

  test "insert works" do
    assert %Person{name: "bleep", age: 2, _id: id} = %Person{name: :bleep, age: 2} |> Repo.insert
    assert id |> is_binary
  end

  test "get works" do
    assert %Person{} = person1 = %Person{name: :bleep, age: 2} |> Repo.insert
    assert %Person{} = person2 = Repo.get(Person, person1._key)
    assert person1 == person2
  end

  test "update works" do
    assert %Person{} = person1 = %Person{name: :bleep, age: 2} |> Repo.insert
    assert %Person{} = person2 = %{ person1 | name: :bloop } |> Repo.update
    assert %Person{} = person3 = Repo.get(Person, person1._key)

    assert person1._id == person2._id
    assert person1._id == person3._id

    assert person1._rev != person2._rev
    assert person2._rev == person3._rev

    assert person1.name == "bleep"
    assert person2.name == "bloop"
    assert person3.name == "bloop"

    assert person2 == person3
  end

  test "remove works" do
    assert %Person{} = person     = %Person{name: :blep, age: 3} |> Repo.insert
    assert %Person{} = Repo.remove(person)
    assert Repo.get(Person, person._key) == nil
  end


end
