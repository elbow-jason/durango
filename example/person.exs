defmodule DurangoExample.Person do
  use Durango.Document

  document :persons do
    field :name, :string
    field :age,  :integer
  end
end
