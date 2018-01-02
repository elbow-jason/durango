defmodule Durango.Api.AQL do
  @moduledoc """
  Source for paths, methods, and descriptions is
  "Support -> Rest API -> AQL" section of ArangoDB web ui.
  """

  @doc """
  GET /_api/aqlfunction
  Return registered AQL user functions
  """
  def list_functions(repo) do
    Durango.Api.get(repo, "/_api/aqlfunction")
  end

  @doc """
  POST /_api/aqlfunction
  Create AQL user function
  """
  def create_function(repo, func) do
    Durango.Api.post(repo, "/_api/aqlfunction", func)
  end

  @doc """
  DELETE /_api/aqlfunction/{name}
  Remove existing AQL user function
  """
  def remove_function(repo, name) do
    Durango.Api.delete(repo, "/_api/aqlfunction/#{name}")
  end

  @doc """
  POST /_api/explain
  Explain an AQL query
  """
  def explain_query(repo, query) do
    Durango.Api.post(repo, "/_api/explain", query)
  end

  @doc """
  POST /_api/query
  Parse an AQL query
  """
  def parse_query(repo, query) do
    Durango.Api.post(repo, "/_api/query", query)
  end

  @doc """
  DELETE /_api/query-cache
  Clears any results in the AQL query cache
  """
  def clear_query_cache(repo) do
    Durango.Api.delete(repo, "/_api/query-cache")
  end

  @doc """
  GET /_api/query-cache/properties
  Returns the global properties for the AQL query cache
  """
  def query_cache_properties(repo) do
    Durango.Api.get(repo, "/_api/query-cache/properties")
  end

  @doc """
  PUT /_api/query-cache/properties
  Globally adjusts the AQL query result cache properties
  """
  def change_query_cache_properties(repo, changes) do
    Durango.Api.put(repo, "/_api/query-cache/properties", changes)
  end

  @doc """
  GET /_api/query/current
  Returns the currently running AQL queries
  """
  def running_queries(repo) do
    Durango.Api.get(repo, "/_api/query/current")
  end

  @doc """
  GET /_api/query/properties
  Returns the properties for the AQL query tracking
  """
  def query_tracking_properties(repo) do
    Durango.Api.get(repo, "/_api/query/properties")
  end

  @doc """
  PUT /_api/query/properties
  Changes the properties for the AQL query tracking
  """
  def change_query_tracking_properties(repo) do
    Durango.Api.put(repo, "/_api/query/properties")
  end


  @doc """
  DELETE /_api/query/slow
  Clears the list of slow AQL queries
  """
  def clear_slow_queries(repo) do
    Durango.Api.delete(repo, "/_api/query/slow")
  end

  @doc """
  GET /_api/query/slow
  Returns the list of slow AQL queries
  """
  def list_slow_queries(repo) do
    Durango.Api.get(repo, "/_api/query/slow")
  end

  @doc """
  DELETE /_api/query/{query-id}
  Kills a running AQL query
  """
  def kill_query(repo, query_id) do
    Durango.Api.delete(repo, "/_api/query/#{query_id}")
  end

end
