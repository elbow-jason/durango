defmodule Durango.Repo.Auth do

  def start_table do
    :ets.new(__MODULE__, [:set, :public, :named_table])
  end

  def refresh_token(repo) do
    config = repo.__config__()
    body = Jason.encode!(%{
      username: config[:username],
      password: config[:password],
    })
    url =
      config
      |> Map.fetch!(:uri)
      |> Map.put(:path, "/_open/auth")
      |> to_string
    case HTTPoison.request(:post, url, body, [], []) do
      {:ok, %{status_code: 200, body: body}} ->
        Jason.decode!(body)
      {:ok, %{status_code: code} = resp} ->
        raise "Invalid Durango.Repo.Auth response #{code} for #{config[:name]}. Response: #{inspect resp}"
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise "Invalid Durango.Repo.Auth response #{inspect reason} for #{config[:name]}"
    end
    |> case do
      %{"jwt" => token} ->
        store_token(repo, token)
        :ok
      resp ->
        raise "Invalid Durango.Repo.Auth response body. Got #{inspect resp}"
    end
  end

  def store_token(repo, token) do
    :ets.insert(__MODULE__, {repo.__config__().name, token})
    :ok
  end

  def fetch_token(repo) do
    name = repo.__config__().name
    :ets.lookup(__MODULE__, name)
    |> case do
      [{^name, token}] ->
        token
      _ ->
        nil
    end
  end

  def header!(repo) do
    case fetch_token(repo) do
      nil ->
        raise "Durango.Repo.Auth had no token for #{repo.__config__().name}"
      token when is_binary(token) ->
        {"Authorization", "Bearer "<>token}
    end
  end
  def headers!(repo) do
    [
      header!(repo),
    ]
  end

  # def headers!(repo) do
  #   username = repo.__config__(:username)
  #   password = repo.__config__(:password)
  #   combo = "#{username}:#{password}"
  #   ["Authorization": "Basic "<>Base.encode64(combo)]
  # end

end
