defmodule Durango.Api do


  # def database_current(repo) do
  #   get(repo, "/_api/database/current")
  # end
  #
  # def list_databases(repo) do
  #   get(repo, "/_api/database")
  # end
  #
  # def get_time(repo) do
  #   get(repo, "/_admin/time")
  # end
  #
  # def get_aqlfunctions(repo) do
  #   get(repo, "/_api/aqlfunction")
  # end

  def path(repo, subpath) do
    "/"<>Path.join([
      "_db",
      repo.__config__()[:database],
      subpath,
    ])
  end

  def render_body(body) when is_binary(body) do
    body
  end
  def render_body(body) when is_atom(body) do
    to_string(body)
  end
  def render_body(body) when is_list(body) when is_map(body) do
    Jason.encode!(body)
  end

  def get(repo, subpath, query_params \\ %{}) do
    do_request(repo, :get, subpath, "", query_params)
  end

  def post(repo, subpath, body \\ "", query_params \\ %{}) do
    do_request(repo, :post, subpath, body, query_params)
  end

  def put(repo, subpath, body \\ "", query_params \\ %{}) do
    do_request(repo, :put, subpath, body, query_params)
  end

  def delete(repo, subpath, body \\ "", query_params \\ %{}) do
    do_request(repo, :delete, subpath, body, query_params)
  end

  def patch(repo, subpath, body \\ "", query_params \\ %{}) do
    do_request(repo, :patch, subpath, body, query_params)
  end

  defp do_request(repo, method, subpath, body, query_params) do
    path = path(repo, subpath)
    body = render_body(body)
    Durango.Repo.Client.send_request(repo, method, path, body, query_params)
  end

end
