defmodule Durango.Api.Database do

  @doc """
  GET /_api/database
  List of databases
  """
  def list(repo) do
    Durango.Api.get(repo, "/_api/database")
  end

  @doc """
  POST /_api/database
  Create database
  """
  def create(repo, name) when is_binary(name) do
    create(repo, %{name: name})
  end
  def create(repo, params) when is_map(params) do
    Durango.Api.post(repo, " /_api/database", params)
  end

  @doc """
  GET /_api/database/current
  Information of the database
  """
  def info(repo) do
    Durango.Api.get(repo, "/_api/database/current")
  end


  @doc """
  GET /_api/database/user
  List of accessible databases
  """
  def user_databases(repo) do
    Durango.Api.get(repo, "/_api/database/user")
  end

  @doc """
  DELETE /_api/database/{database-name} Drop database
  """
  def drop(repo, name) do
    Durango.Api.delete(repo, "/_api/database/#{name}")
  end

end
