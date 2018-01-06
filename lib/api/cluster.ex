defmodule Durango.Api.Cluster do

  @doc """
  DELETE /_admin/cluster-test
  Delete cluster roundtrip
  """
  def delete_roundtrip(repo) do
    Durango.Api.get(repo, "/_admin/clusterStatistics")
  end

  @doc """
  GET /_admin/cluster-test
  Execute cluster roundtrip

  HEAD, POST, and PUT for `/_admin/cluster-test`
  are redundant and have been omitted from Durango.
  """
  def execute_roundtrip(repo) do
    Durango.Api.get(repo, "/_admin/cluster-test")
  end

  @doc """
  PATCH /_admin/cluster-test
  Update cluster roundtrip
  """
  def update_cluster_roundtrip(repo, updates) do
    Durango.Api.patch(repo, "/_admin/cluster-test", updates)
  end

  @doc """
  GET /_admin/clusterCheckPort
  Check port
  """
  def check_port(repo) do
    Durango.Api.get(repo, "/_admin/clusterCheckPort")
  end

  @doc """
  GET /_admin/clusterStatistics Queries statistics of DBserver
  """
  def statistics(repo) do
    Durango.Api.get(repo, "/_admin/clusterStatistics")
  end

end
