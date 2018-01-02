defmodule Durango.Repo do
  use GenServer

  defmacro __using__(opts) do
    quote do
      @name unquote(opts[:name])
      if is_nil(@name) do
        msg = "Durango.Repo requires a :name keyword when using `use Durango.Repo`"
        raise %CompileError{description: msg}
      end

      @config   [name: @name] ++ Application.get_env(:durango, @name)
      @username @config[:username]
      @password @config[:password]
      @database @config[:database]

      @uri %URI{
        scheme: @config[:scheme],
        host:   @config[:host],
        port:   @config[:port],
      }

      def __config__(),           do: @config
      def __config__(:name),      do: @name
      def __config__(:username),  do: @username
      def __config__(:password),  do: @password
      def __config__(:uri),       do: @uri
      def __config__(:database),  do: @database

      def start_link(_) do
        GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      end

      def init(_) do
        refresh_token()
        {:ok, nil}
      end

      defp refresh_token() do
        Durango.Repo.Auth.refresh_token(__MODULE__)
        Process.send_after(self(), :refresh_token, 1000 * 60 * 60 * 12) # 12 hrs
      end

      def handle_info(:refresh_token) do
        refresh_token()
      end

    end

  end


end
