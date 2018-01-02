defmodule Durango.Api.Graph do

  @doc """
  GET    /_api/gharial
  List all graphs
  """
  def list(repo) do
    Durango.Api.get(repo, "/_api/gharial")
  end

  @doc """
  POST /_api/gharial
  Create a graph
  """
  def create(repo, params) do
    Durango.Api.post(repo, "/_api/gharial", params)
  end

  @doc """
  DELETE /_api/gharial/{graph-name}
  Drop a graph
  """
  def delete(repo, name) do
    Durango.Api.get(repo, "/_api/gharial/#{name}")
  end

  @doc """
  GET /_api/gharial/{name}
  Get a graph
  """
  def get(repo, name) do
    Durango.Api.get(repo, "/_api/gharial/#{name}")
  end

end
