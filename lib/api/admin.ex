defmodule Durango.Api.Admin do
  @moduledoc """
    Source for paths, methods, and descriptions is
    "Support -> Rest API" tab of ArangoDB web ui.
  """

  @doc """
    GET /_admin/database/target-version
    Return the required version of the database
  """
  def target_version(repo) do
    Durango.Api.get(repo, "/_admin/database/target-version")
  end

  @doc """
    GET /_admin/echo
    Return current request
  """
  def echo(repo) do
    Durango.Api.get(repo, "/_admin/echo")
  end

  @doc """
  POST /_admin/execute
  Execute program

  This endpoint only works if the
  server has set `--javascript.allow-admin-execute true`
  configured. Otherwise it errors with a 404.

  This is a dangerous endpoint because it could evaluate
  user-defined code.

  The official docs recommend leaving this endpoint disabled
  in production.
  """
  def execute(repo, expr) do
    Durango.Api.post(repo, "/_admin/execute", expr)
  end

  @doc """
  GET /_admin/log
  Read global logs from the server
  """
  def logs(repo) do
    Durango.Api.get(repo, "/_admin/log")
  end

  @doc """
  GET /_admin/log/level
  Return the current server loglevel
  """
  def log_level(repo) do
    Durango.Api.get(repo, "/_admin/log/level")
  end

  @doc """
  # PUT /_admin/log/level
  # Modify and return the current server loglevel
  """
  def change_log_level(repo, levels) do
    Durango.Api.put(repo, "/_admin/log/level", levels)
  end

  @doc """
  GET /_admin/long_echo
  Return current request and continues
  """
  def long_echo(repo) do
    Durango.Api.get(repo, "/_admin/long_echo")
  end

  @doc """
  POST /_admin/routing/reload
  Reloads the routing information
  """
  def routing_reload(repo) do
    Durango.Api.post(repo, "/_admin/routing/reload")
  end

  @doc """
  GET /_admin/server/id
  Return id of a server in a cluster
  """
  def server_id(repo) do
    Durango.Api.get(repo, "/_admin/server/id")
  end

  @doc """
  GET /_admin/server/role
  Return role of a server in a cluster
  """
  def server_role(repo) do
    Durango.Api.get(repo, "/_admin/server/role")
  end

  @doc """
  DELETE /_admin/shutdown
  Initiate shutdown sequence
  """
  def shutdown(repo) do
    Durango.Api.delete(repo, "/_admin/shutdown")
  end

  @doc """
  GET /_admin/statistics
  Read the statistics
  """
  def statistics(repo) do
    Durango.Api.get(repo, "/_admin/statistics")
  end

  @doc """
  GET /_admin/statistics-description
  Statistics description
  """
  def statistics_description(repo) do
    Durango.Api.get(repo, "/_admin/statistics-description")
  end

  @doc """
  POST /_admin/test
  Runs tests on server
  """
  def run_tests(repo) do
    Durango.Api.post(repo, "/_admin/test")
  end

  @doc """
  GET /_admin/time
  Return system time
  """
  def time(repo) do
    Durango.Api.get(repo, "/_admin/time")
  end

  @doc """
  GET /_api/cluster/endpoints
  Get information about all coordinator endpoints
  """
  def list_cluster_endpoints(repo) do
    Durango.Api.get(repo, "/_api/cluster/endpoints")
  end

  @doc """
  GET /_api/endpoint
  Return list of all endpoints
  """
  def list_endpoints(repo) do
    Durango.Api.get(repo, "/_api/endpoint")
  end

  @doc """
  GET /_api/engine
  Return server database engine type
  """
  def engine(repo) do
    Durango.Api.get(repo, "/_api/engine")
  end

  @doc """
  POST /_api/tasks
  Creates a task
  """
  def create_task(repo, task) do
    Durango.Api.post(repo, "/_api/tasks", task)
  end

  @doc """
  PUT /_api/tasks/{id}
  Creates a task with id
  """
  def create_task(repo, task, id) do
    Durango.Api.put(repo, "/_api/tasks/#{id}", task)
  end

  @doc """
  # GET /_api/tasks/
  # Fetch all tasks or one task
  """
  def list_tasks(repo) do
    Durango.Api.get(repo, "/_api/tasks/")
  end

  @doc """
  DELETE /_api/tasks/{id}
  Deletes the task with id
  """
  def delete_task(repo, id) do
    Durango.Api.delete(repo, "/_api/tasks/#{id}")
  end

  @doc """
  GET /_api/tasks/{id}
  Fetch one task with id
  """
  def fetch_task(repo, id) do
    Durango.Api.get(repo, "/_api/tasks/#{id}")
  end

  @doc """
  GET /_api/version
  Return server version
  """
  def version(repo) do
    Durango.Api.get(repo, "/_api/version")
  end

end
