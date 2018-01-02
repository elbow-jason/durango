defmodule Durango.Api.Documents do

  @doc """
  DELETE /_api/document/{id}
  Removes multiple documents
  """
  def delete(repo, id) do
    Durango.Api.delete(repo, "/_api/document/#{id}")
  end

  @doc """
  PATCH /_api/document/{id}
  Update documents
  """
  def update(repo, id, changes) do
    Durango.Api.patch(repo, "/_api/document/#{id}", changes)
  end

  @doc """
  POST /_api/document/{collection}
  Create document
  """
  def create(repo, collection, object, query_params \\ %{}) do
    Durango.Api.post(repo, "/_api/document/#{collection}", object, query_params)
  end

  @doc """
  PUT /_api/document/{collection}
  Replace documents
  """
  def replace(repo, collection, object, query_params \\ nil) do
    Durango.Api.put(repo, "/_api/document/#{collection}", object, query_params)
  end

  @doc """
  PUT /_api/simple/all-keys
  Read all documents
  """
  def all_documents(repo, collection) when is_binary(collection) do
    all_documents(repo, %{collection: collection})
  end
  def all_documents(repo, params) when is_map(params) do
    Durango.Api.put(repo, "/_api/simple/all-keys", params)
  end

end
