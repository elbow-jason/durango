defmodule Durango.Api.Request do
  alias Durango.Api.Request

  defstruct [
    body:     nil,
    path:     nil,
    query:    nil,
    method:   nil,
    repo:     nil,
    headers:  nil,
  ]

  def new(params) when is_map(params) do
    %Request{
      repo:     params.repo,
      method:   params.method,
      path:     params.path,
      body:     Map.get(params, :body, ""),
      query:    Map.get(params, :query, nil),
      headers:  Map.get(params, :headers, []),
    }
  end

  def render_querystring(%Request{query: query}) do
    render_querystring(query)
  end
  def render_querystring(query) when is_map(query) do
    query
    |> URI.encode_query
    |> render_querystring
  end
  def render_querystring("?"<>params) do
    render_querystring(params)
  end
  def render_querystring(params) when is_binary(params) do
    params
  end
  def render_querystring(_) do
    nil
  end

  def render_body(%Request{body: body}) do
    render_body(body)
  end
  def render_body(body) when is_binary(body) do
    body
  end
  def render_body(body) when is_list(body) when is_map(body) do
    Jason.encode!(body)
  end
  def render_body(_) do
    ""
  end



end
