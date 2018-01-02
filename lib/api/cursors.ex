defmodule Durango.Api.Cursors do

  @doc """
  POST /_api/cursor
  Create cursor
  """
  def create_cursor(repo, params) do
    Durango.Api.post(repo, "/_api/cursor", params)
  end

  @doc """
  DELETE /_api/cursor/{cursor-identifier}
  Delete cursor
  """
  def delete_cursor(repo, id) do
    Durango.Api.delete(repo, "/_api/cursor/#{id}")
  end

  @doc """
  PUT /_api/cursor/{cursor-identifier}
  Read next batch from cursor
  """
  def next_batch(repo, id) do
    Durango.Api.put(repo, "/_api/cursor/#{id}")
  end

end
