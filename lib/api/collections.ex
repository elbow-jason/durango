defmodule Durango.Api.Collections do

  @doc """
  GET /_api/collection
  reads all collections
  """
  def list_collections(repo) do
    Durango.Api.get(repo, "/_api/collection")
  end

  @doc """
  POST /_api/collection
  Create collection
  """
  def create_collection(repo, name) when is_binary(name) do
    create_collection(repo, %{name: name})
  end
  def create_collection(repo, params) when is_map(params) do
    Durango.Api.post(repo, "/_api/collection", params)
  end

  @doc """
  DELETE /_api/collection/{collection-name}
  Drops a collection
  """
  def delete_collection(repo, name) do
    Durango.Api.delete(repo, "/_api/collection/#{name}")
  end

  @doc """
  GET /_api/collection/{collection-name}
  Return information about a collection
  """
  def info(repo, name) do
    Durango.Api.get(repo, "/_api/collection/#{name}")
  end

  @doc """
  GET /_api/collection/{collection-name}/checksum
  Return checksum for the collection
  """
  def checksum(repo, name) do
    Durango.Api.get(repo, "/_api/collection/#{name}/checksum")
  end

  @doc """
  GET /_api/collection/{collection-name}/count
  Return number of documents in a collection
  """
  def document_count(repo, name) do
    Durango.Api.get(repo, "/_api/collection/#{name}/count")
  end

  @doc """
  GET /_api/collection/{collection-name}/figures
  Return statistics for a collection
  """
  def statistics(repo, name) do
    Durango.Api.get(repo, "/_api/collection/#{name}/figures")
  end

  @doc """
  PUT /_api/collection/{collection-name}/load Load collection
  """
  def load_collection(repo, name) do
    Durango.Api.get(repo, "/_api/collection/#{name}/load")
  end

  @doc """
  PUT /_api/collection/{collection-name}/loadIndexesIntoMemory
  Load Indexes into Memory
  """
  def load_indexes(repo, name) do
    Durango.Api.put(repo, "/_api/collection/#{name}/loadIndexesIntoMemory")
  end

  @doc """
  GET /_api/collection/{collection-name}/properties Read properties of a collection
  """
  def properties(repo, name) do
    Durango.Api.get(repo, "/_api/collection/#{name}/properties")
  end

  @doc """
  PUT /_api/collection/{collection-name}/properties
  Change properties of a collection
  """
  def change_properties(repo, name, changes) do
    Durango.Api.put(repo, "/_api/collection/#{name}/properties", changes)
  end

  @doc """
  PUT /_api/collection/{collection-name}/rename Rename collection
  """
  def rename(repo, name, new_name) do
    Durango.Api.put(repo, "/_api/collection/#{name}/rename", %{name: new_name})
  end

  @doc """
  GET /_api/collection/{collection-name}/revision
  Return collection revision id
  """
  def revision_id(repo, name) do
    Durango.Api.get(repo, "/_api/collection/#{name}/revision")
  end

  @doc """
  PUT /_api/collection/{collection-name}/rotate
  Rotate journal of a collection
  """
  def rotate_journal(repo, name) do
    Durango.Api.get(repo, "/_api/collection/#{name}/rotate")
  end

  @doc """
  PUT /_api/collection/{collection-name}/truncate
  Truncate collection
  """
  def truncate(repo, name) do
    Durango.Api.put(repo, "/_api/collection/#{name}/truncate")
  end

  @doc """
  PUT /_api/collection/{collection-name}/unload
  Unload collection
  """
  def unload(repo, name) do
    Durango.Api.put(repo, "/_api/collection/#{name}/unload")
  end

end
