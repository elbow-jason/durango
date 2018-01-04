defmodule DurangoQueryTest do
  use ExUnit.Case
  doctest Durango.Query
  require Durango.Query
  alias Durango.Query

  def normalize(string) do
    string
    |> String.replace(~r/\s{1,}/, " ")
    |> String.trim
  end

  test "query can parse a for and return" do
    assert [
      for: p,
      in: :persons,
      return: p,
    ]
    |> Query.query()
    |> to_string == "FOR p IN persons RETURN p"
  end

  test "query can parse a for, filter, and return" do
    assert [
      for: p,
      in: :persons,
      filter: p.name == "willy",
      return: p
    ]
    |> Query.query()
    |> to_string == "FOR p IN persons FILTER p.name == \"willy\" RETURN p"
  end

  test "query can parse a for, limit, and return" do
    assert [
      for: p,
      in: :persons,
      limit: 10,
      return: p
    ]
    |> Query.query()
    |> to_string == "FOR p IN persons LIMIT 10 RETURN p"
  end

  test "query can parse a for, limit with a bound_var, and return" do
    counted = 10
    query = Query.query([
      for: p,
      in: :persons,
      limit: ^counted,
      return: p
    ])
    assert to_string(query) == "FOR p IN persons LIMIT @counted RETURN p"
    assert query.bound_variables == %{
      counted: %Durango.Dsl.BoundVar{key: :counted, validations: [], value: 10},
    }
  end

  test "query can parse a pinned/interpolated value in an expression" do
    min_age = 18
    query = Query.query([
      for: u,
      in: :users,
      filter: u.age >= ^min_age,
      return: u,
    ])
    assert to_string(query) == "FOR u IN users FILTER u.age >= @min_age RETURN u"
    assert query.bound_variables == %{min_age: %Durango.Dsl.BoundVar{key: :min_age, validations: [], value: 18}}
  end

  test "query can parse a dot_access return value" do
    query = Query.query([
      for: u,
      in: :users,
      filter: u.age >= 18,
      return: u.age,
    ])
    assert to_string(query) == "FOR u IN users FILTER u.age >= 18 RETURN u.age"
    assert query.bound_variables == %{}
  end


  test "query can parse a map return value" do
    query = Query.query([
      for: u,
      in: :users,
      filter: u.age >= 18,
      return: %{age: u.age, name: u.first_name},
    ])
    assert to_string(query) == "FOR u IN users FILTER u.age >= 18 RETURN { age: u.age, name: u.first_name }"
    assert query.bound_variables == %{}
  end

  test "query can parse a return document" do
    query = Query.query([
      return: document("123"),
    ])
    assert to_string(query) == ~s/RETURN DOCUMENT("123")/
    assert query.bound_variables == %{}
  end


  test "query can parse a `for: a in :things` type of query" do
    q = Query.query([for: a in :thing, return: a])
    assert to_string(q) == "FOR a IN thing RETURN a"
  end

  test "query can parse a multi-variable for expression" do
    q = Query.query([
      for: {a, b, c} in :things,
        return: %{a: a, b: b, c: c}
    ])
    assert to_string(q) == "FOR a, b, c IN things RETURN { a: a, b: b, c: c }"
    assert q.local_variables == [:c, :b, :a]
  end

  test "query can parse a long query" do
    expected = normalize """
      FOR meetup IN meetups
        FILTER "NOSQL" IN meetup.topics
        FOR city IN OUTBOUND meetup held_in
          FOR programmer IN INBOUND city lives_in
            FILTER programmer.notify
            FOR cname IN city_names
              FILTER cname.city == city._key AND cname.lang == programmer.lang
              INSERT { email: programmer.email, meetup: meetup._key, city: cname.name }
              INTO invitations
    """


    q = Query.query([
      for: meetup, in: :meetups,
        filter: "NOSQL" in meetup.topics,
        for: city, in_outbound: {meetup, :held_in},
          for: programmer, in_inbound: {city, :lives_in},
            filter: programmer.notify,
            for: cname, in: :city_names,
              filter: cname.city == city._key and cname.lang == programmer.lang,
              insert: %{
                email: programmer.email,
                meetup: meetup._key,
                city: cname.name,
              },
              into: :invitations
    ])
    assert to_string(q) == expected
  end

  test "query can parse another long query" do
    expected = normalize """
        FOR v, e, p IN 1..5 OUTBOUND "circles/A" GRAPH "traversalGraph"
      FILTER p.edges[0].theTruth == true
         AND p.edges[1].theFalse == false
      FILTER p.vertices[1]._key == "G"
      RETURN p
    """

    q = Query.query([
      for: {v, e, p} in 1..5,
      outbound: "circles/A",
      graph: "traversalGraph",
      filter: p.edges[0].theTruth == true and p.edges[1].theFalse == false,
      filter: p.vertices[1]._key == "G",
      return: p
    ])
    assert to_string(q) == expected
  end

  test "query can handle an interpolated dot access" do
    my_map = %{name: "Jason"}
    q = Query.query(return: ^my_map.name)
    assert to_string(q) == "RETURN @my_map_name"
    assert q.bound_variables == %{"my_map_name" => %Durango.Dsl.BoundVar{key: "my_map_name", validations: [], value: "Jason"}}
  end

  test "query can handle star bracket access [:ALL]" do
    expected = normalize """
      FOR v, e, p
      IN 1..5
      OUTBOUND "circles/A"
      GRAPH "traversalGraph"
      FILTER p.edges[*].theTruth ALL == true
      RETURN p
    """
    q = Query.query([
      for: {v, e, p},
      in:  1..5,
      outbound: "circles/A",
      graph: "traversalGraph",
      filter: p.edges[:ALL].theTruth == true,
      return: p,
    ])
    assert to_string(q) == expected
  end

  test "query can handle star bracket access [:ANY]" do
    expected = normalize """
      FOR v, e, p
      IN 1..5
      OUTBOUND "circles/A"
      GRAPH "traversalGraph"
      FILTER p.edges[*].theTruth ANY == true
      RETURN p
    """
    q = Query.query([
      for: {v, e, p},
      in:  1..5,
      outbound: "circles/A",
      graph: "traversalGraph",
      filter: p.edges[:ANY].theTruth == true,
      return: p,
    ])
    assert to_string(q) == expected

  end

  test "query can handle star bracket access [:NONE]" do
    expected = normalize """
      FOR v, e, p
      IN 1..5
      OUTBOUND "circles/A"
      GRAPH "traversalGraph"
      FILTER p.edges[*].theTruth NONE == true
      RETURN p
    """
    q = Query.query([
      for: {v, e, p},
      in:  1..5,
      outbound: "circles/A",
      graph: "traversalGraph",
      filter: p.edges[:NONE].theTruth == true,
      return: p,
    ])
    assert to_string(q) == expected
  end


  test "query can handle interpolated bracket_access [^some_var]" do
    some_key = "name"
    expected = normalize """
      FOR v, e, p
      IN 1..5
      OUTBOUND "circles/A"
      GRAPH "traversalGraph"
      FILTER p.edges[@some_key].theTruth == true
      RETURN p
    """
    q = Query.query([
      for: {v, e, p},
      in:  1..5,
      outbound: "circles/A",
      graph: "traversalGraph",
      filter: p.edges[^some_key].theTruth == true,
      return: p,
    ])
    assert to_string(q) == expected
    assert q.bound_variables == %{:some_key =>%Durango.Dsl.BoundVar{key: :some_key, validations: [], value: "name"}}
  end

  test "query can handle a subquery and CURRENT variable" do
    expected = normalize """
      FOR u IN users
        RETURN {
            name: u.name,
            friends: u.friends[* FILTER CONTAINS(CURRENT.name, "a") AND CURRENT.age > 40
                LIMIT 2
                RETURN CONCAT(CURRENT.name, " is ", CURRENT.age)
            ]
        }
    """
    q = Query.query([
      for: u in :users,
        return: %{
          name: u.name,
          friends: inline(u.friends, [
            filter: contains(CURRENT.name, "a") and CURRENT.age > 40,
            limit: 2,
            return: concat(CURRENT.name, " is ", CURRENT.age)
          ])
        }
    ])
    assert to_string(q) == expected
    assert q.local_variables == [:u] # current is only available in the object
  end

  test "query can handle let statement" do
    expected = normalize """
    LET doc = { foo: { bar: "baz" } }
    RETURN doc
    """
    q = Query.query([
      let: doc = %{foo: %{bar: "baz"}},
      return: doc,
    ])
    assert to_string(q) == expected
  end

  test "query can handle stringy bracket access" do
    expected = normalize """
    FOR u IN users RETURN u["details"]["name"]
    """
    q = Query.query([
      for: u in :users,
      return: u["details"]["name"],
    ])
    assert to_string(q) == expected
  end

  test "query can handle multi pinned-var bracket access" do
    expected = normalize """
    LET doc = { foo: { bar: "baz" } }
    RETURN doc[@key1][@key2]
    """
    key1 = :foo
    key2 = :bar
    q = Query.query([
      let: doc = %{foo: %{bar: "baz"}},
      return: doc[^key1][^key2],
    ])
    assert to_string(q) == expected
    assert q.bound_variables == %{
      key1: %Durango.Dsl.BoundVar{key: :key1, validations: [], value: :foo},
      key2: %Durango.Dsl.BoundVar{key: :key2, validations: [], value: :bar},
    }
  end

  test "query can handle update and with" do
    expected = normalize """
    FOR u IN users
      UPDATE u WITH { gender: TRANSLATE(u.gender, { m: "male", f: "female" }) } IN users
    """
    q = Query.query([
      for: u in :users,
      update: u, with: %{
        gender: translate(u.gender, %{m: "male", f: "female"})
      },
      in: users,
    ])
    # IO.inspect(q.tokens, label: "the_tokens")
    assert to_string(q) == expected
  end

  test "query can handle sort with one field" do
    expected = normalize """
      FOR p IN persons
        SORT p.age
        RETURN p
    """
    q = Query.query([
      for: p in :persons,
      sort: p.age,
      return: p,
    ])
    assert to_string(q) == expected
  end

  test "query can handle sort with multiple fields" do
    expected = normalize """
      FOR p IN persons
        SORT p.age, p.fist_name, p.last_name
        RETURN p
    """
    q = Query.query([
      for: p in :persons,
      sort: [p.age, p.fist_name, p.last_name],
      return: p,
    ])
    assert to_string(q) == expected
  end

  test "query can handle sort with multiple fields and an order" do
    expected = normalize """
      FOR p IN persons
        SORT p.age, p.fist_name, p.last_name DESC
        RETURN p
    """
    q = Query.query([
      for: p in :persons,
      sort: {[p.age, p.fist_name, p.last_name], :DESC},
      return: p,
    ])
    assert to_string(q) == expected
  end

  test "query can handle sort with an order" do
    expected = normalize """
      FOR p IN persons
        SORT p._id DESC
        RETURN p
    """
    q = Query.query([
      for: p in :persons,
      sort: {p._id, :DESC},
      return: p,
    ])
    assert to_string(q) == expected
  end



  @tag current: true
  test "query can handle a subquery" do
    expected = normalize """
    FOR p IN persons
      LET recommendations = (
        FOR r IN recommendations
          FILTER p.id == r.person_id
          SORT p.rank DESC
          LIMIT 10
          RETURN r
      )
      RETURN { person: p, recommendations: recommendations }
    """
    q = Query.query([
      for: p in :persons,
      let: recommendations = subquery([
        for: r, in: :recommendations,
        filter: p.id == r.person_id,
        sort: {p.rank, :desc},
        limit: 10,
        return: r
      ]),
      return: %{person: p, recommendations: recommendations }
    ])

    assert to_string(q) == expected
  end

  test "query can handle a simple remove" do
    expected = normalize """
    FOR u IN users
      REMOVE u IN users
    """
    q = Query.query([
      for: u in :users,
      remove: u in :users
      ])
    assert to_string(q) == expected
  end

  test "query can handle a remove by attr" do
    expected = normalize """
      FOR u IN users
        REMOVE u._key IN users
    """
    q = Query.query([
      for: u in :users,
      remove: u._key in :users
    ])
    assert to_string(q) == expected
  end

  test "query can handle remove by object" do
    expected = normalize """
    FOR u IN users
      REMOVE { _key: u._key } IN users
    """
    q = Query.query([
      for: u in :users,
      remove: %{_key: u._key } in :users
    ])
    assert to_string(q) == expected
  end

  test "query can handle a remove with an embedded func" do
    expected = normalize """
      FOR i IN 1..1000
        REMOVE { _key: CONCAT("test", i) } IN users
    """
    q = Query.query([
      for: i in 1..1000,
      remove: %{ _key: concat("test", i) } in :users,
    ])
    assert to_string(q) == expected
  end

  test "query can handle a remove with options" do
    expected = normalize """
      FOR i IN 1..1000
      REMOVE { _key: CONCAT("test", i) } IN users OPTIONS { ignoreErrors: true }
    """
    q = Query.query([
      for: i in 1..1000,
      remove: %{ _key: concat("test", i) } in :users,
      options: %{ ignoreErrors: true }
    ])
    assert to_string(q) == expected
  end

  test "OLD works var is available after remove" do
    expected = normalize """
    FOR u IN users
      REMOVE u IN users
      LET removed = OLD
      RETURN removed._key
    """

    q = Query.query([
      for: u in :users,
      remove: u in :users,
      let: removed = OLD,
      return: removed._key,
      ])

    assert to_string(q) == expected
    assert :OLD in q.local_variables
  end


  test "query can handle update in" do
    expected = normalize """
    FOR u IN users
      UPDATE {
        _key: u._key,
        name: CONCAT(u.first_name, " ", u.last_name)
      }
      IN users
    """

    q = Query.query([
      for: u in :users,
      update: %{
        _key: u._key,
        name: concat(u.first_name, " ", u.last_name),
      },
      in: :users,
    ])

    assert to_string(q) == expected
  end

  test "query can handle update with in syntax" do
    expected = normalize """
      FOR u IN users
        UPDATE u._key
        WITH { name: CONCAT(u.first_name, " ", u.last_name) }
        IN users
    """

    q = Query.query([
      for: u in :users,
        update: u._key,
        with: %{
          name: concat(u.first_name, " ", u.last_name),
        },
        in: :users,
    ])

    assert to_string(q) == expected
  end

  test "query can handle update that uses NEW varialbe and OLD variable" do
    expected = normalize """
    FOR u IN users
      UPDATE u WITH { value: "test" }
      RETURN { before: OLD, after: NEW }
    """

    q = Query.query([
      for: u in :users,
        update: u,
        with: %{
          value: "test",
        },
        return: %{ before: OLD, after: NEW },
    ])

    assert to_string(q) == expected
  end



  test "query can handle REPLACE IN" do
    expected = normalize """
    FOR u IN users
      REPLACE {
        _key: u._key,
        name: CONCAT(u.first_name, " ", u.last_name)
      }
      IN users
    """

    q = Query.query([
      for: u in :users,
      replace: %{
        _key: u._key,
        name: concat(u.first_name, " ", u.last_name),
      },
      in: :users,
    ])

    assert to_string(q) == expected
  end

  test "query can handle REPLACE WITH syntax" do
    expected = normalize """
      FOR u IN users
        REPLACE u._key
        WITH { name: CONCAT(u.first_name, " ", u.last_name) }
        IN users
    """

    q = Query.query([
      for: u in :users,
        replace: u._key,
        with: %{
          name: concat(u.first_name, " ", u.last_name),
        },
        in: :users,
    ])

    assert to_string(q) == expected
  end

  test "query can handle REPLACE that uses NEW varialbe and OLD variable" do
    expected = normalize """
    FOR u IN users
      REPLACE u WITH { value: "test" }
      RETURN { before: OLD, after: NEW }
    """

    q = Query.query([
      for: u in :users,
        replace: u,
        with: %{
          value: "test",
        },
        return: %{ before: OLD, after: NEW },
    ])

    assert to_string(q) == expected
  end

end
