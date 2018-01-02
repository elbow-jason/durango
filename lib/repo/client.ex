defmodule Durango.Repo.Client do

  def headers(repo) do
      Durango.Repo.Auth.headers!(repo) ++ [
      "Accept": "application/json",
      "Content-Type": "application/json; charset=utf-8",
    ]
    # |> IO.inspect(label: :headers)
  end

  def url(repo, path, query) do
    query = Durango.Api.Request.render_querystring(query)
    repo.__config__(:uri)
    |> Map.put(:path, path)
    |> Map.put(:query, query)
    |> to_string
    |> IO.inspect(label: :url)
  end

  def send_request(repo, method, path, body \\ "", query \\ nil) do
    HTTPoison.request(method, url(repo, path, query), body, headers(repo))
    |> case do
      {:error, _} = err ->
        err
      {:ok, %{status_code: code, body: body}} when code in 200..202 ->
        Jason.decode(body)
      {:ok, %{body: body}} ->
        case Jason.decode(body) do
          {:ok, json} ->
            {:error, json}
          _ ->
            {:error, :invalid_api_response_body}
        end
    end
  end
  def send_request!(repo, method, path, body \\ "", query \\ nil) do
    case HTTPoison.request!(method, url(repo, path, query), body, headers(repo)) do
      %{status_code: code, body: body} when code in 200..202 ->
        Jason.decode(body)
      %{status_code: code} -> # = resp ->
        # IO.puts("Bad Response #{inspect resp}", :stderr)
        raise "Durango.Repo.Client bad response #{code} for connection to #{inspect repo.__config__(:name)}"
      %{reason: reason} ->
        raise "Durango.Repo.Client bad response #{reason} for connection to #{inspect repo.__config__(:name)}"
    end
  end

end
