c "example/repo.exs"
c "example/person.exs"

DurangoExample.Repo.start_link([])

require Durango.Query

alias DurangoExample.Person
alias DurangoExample.Repo
