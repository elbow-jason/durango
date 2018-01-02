defmodule Durango.Api.Bulk do

  @doc """
  POST /_api/batch
  Executes a batch request
  """
  def execute_batch(repo, batch) do
    Durango.Api.post(repo, "/_api/batch", batch)
  end

  @doc """
  POST /_api/export
  Create export cursor
  """
  def create_export_cursor(repo) do
    Durango.Api.post(repo, "/_api/export")
  end

  @doc """
  POST /_api/import#document
  Imports document values
  """
  def import_documents(repo, documents) do
    Durango.Api.post(repo, "/_api/import#document", documents)
  end

  @doc """
  POST /_api/import#json
  Imports documents from JSON
  """
  def import_json(repo, json) do
    Durango.Api.post(repo, "/_api/import#json", json)
  end

end
