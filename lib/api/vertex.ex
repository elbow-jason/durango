defmodule Durango.Api.Vertex do

  @doc """
  GET /_api/gharial/{graph_name}/vertex
  List vertex collections
  """
  def list(repo, graph_name) do
    Durango.Api.get(repo, "/_api/gharial/#{graph_name}/vertex")
  end
  @doc """

  POST /_api/gharial/{graph_name}/vertex
  Add vertex collection
  """
  def add_to_collection(repo, graph_name, params) do
    Durango.Api.post(repo, "/_api/gharial/#{graph_name}/vertex", params)
  end

  @doc """
  DELETE /_api/gharial/{graph_name}/vertex/{collection_name}
  Remove vertex collection
  """
  def delete_collection(repo, graph_name, collection_name) do
    Durango.Api.delete(repo, "/_api/gharial/#{graph_name}/vertex/#{collection_name}")
  end

  @doc """
  POST  /_api/gharial/{graph_name}/vertex/{collection_name}
  Create a vertex
  """
  def create(repo, graph_name, collection_name, params) do
    Durango.Api.post(repo, "/_api/gharial/#{graph_name}/vertex/#{collection_name}", params)
  end

  @doc """
  DELETE /_api/gharial/{graph_name}/vertex/{collection_name}/{vertex_key}
  Remove a vertex
  """
  def delete(repo, graph_name, collection_name, vertex_key) do
    Durango.Api.get(repo, "/_api/gharial/#{graph_name}/vertex/#{collection_name}/#{vertex_key}")
  end

  @doc """
  GET /_api/gharial/{graph_name}/vertex/{collection_name}/{vertex_key}
  Get a vertex
  """
  def get(repo, graph_name, collection_name, vertex_key) do
    Durango.Api.get(repo, "/_api/gharial/#{graph_name}/vertex/#{collection_name}/#{vertex_key}")
  end

  @doc """
  PATCH /_api/gharial/{graph_name}/vertex/{collection_name}/{vertex_key}
  Modify a vertex
  """
  def update(repo, graph_name, collection_name, vertex_key, params) do
    Durango.Api.patch(repo, "/_api/gharial/#{graph_name}/vertex/#{collection_name}/#{vertex_key}", params)
  end

  @doc """
  PUT /_api/gharial/{graph_name}/vertex/{collection_name}/{vertex_key}
  Replace a vertex
  """
  def replace(repo, graph_name, collection_name, vertex_key, params) do
    Durango.Api.put(repo, "/_api/gharial/#{graph_name}/vertex/#{collection_name}/#{vertex_key}", params)
  end

end
