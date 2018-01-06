c "example/repo.exs"
c "example/person.exs"

DurangoExample.Repo.start_link(nil)

require Durango.Query

alias DurangoExample.Person
alias DurangoExample.Repo
