defmodule Durango.Api.Edge do


  @doc """
  GET /_api/gharial/{graph_name}/edge
  List edge definitions
  """
  def list_definitions(repo, graph_name) do
    Durango.Api.get(repo, "/_api/gharial/#{graph_name}/edge")
  end

  @doc """
  POST /_api/gharial/{graph_name}/edge
  Add edge definition
  """
  def create_definition(repo, graph_name, params) do
    Durango.Api.post(repo, "/_api/gharial/#{graph_name}/edge", params)
  end

  @doc """
  DELETE /_api/gharial/{graph_name}/edge/{definition-name}
  Remove an edge definition from the graph
  """
  def delete_definition(repo, graph_name, definition_name) do
    Durango.Api.delete(repo, "/_api/gharial/#{graph_name}/edge/#{definition_name}")
  end

  @doc """
  PUT /_api/gharial/{graph_name}/edge/{definition_name}
  Replace an edge definition
  """
  def replace_definition(repo, graph_name, definition_name, params) do
    Durango.Api.put(repo, "/_api/gharial/#{graph_name}/edge/#{definition_name}", params)
  end

  @doc """
  POST /_api/gharial/{graph_name}/edge/{collection_name}
  Create an edge
  """
  def create(repo, graph_name, collection_name, params) do
    Durango.Api.post(repo, "/_api/gharial/#{graph_name}/edge/#{collection_name}", params)
  end

  @doc """
  DELETE /_api/gharial/{graph_name}/edge/{collection_name}/{edge_key}
  Remove an edge
  """
  def delete(repo, graph_name, collection_name, edge_key) do
    Durango.Api.delete(repo, "/_api/gharial/#{graph_name}/edge/#{collection_name}/#{edge_key}")
  end

  @doc """
  GET /_api/gharial/{graph_name}/edge/{collection_name}/{edge_key}
  Get an edge
  """
  def get(repo, graph_name, collection_name, edge_key) do
    Durango.Api.get(repo, "/_api/gharial/#{graph_name}/edge/#{collection_name}/#{edge_key}")
  end

  @doc """
  PATCH /_api/gharial/{graph_name}/edge/{collection_name}/{edge_key}
  Modify an edge
  """
  def update(repo, graph_name, collection_name, edge_key, params) do
    Durango.Api.patch(repo, "/_api/gharial/#{graph_name}/edge/#{collection_name}/#{edge_key}", params)
  end

  @doc """
  PUT /_api/gharial/{graph_name}/edge/{collection_name}/{edge_key}
  Replace an edge
  """
  def replace(repo, graph_name, collection_name, edge_key) do
    Durango.Api.get(repo, "/_api/gharial/#{graph_name}/edge/#{collection_name}/#{edge_key}")
  end

end
