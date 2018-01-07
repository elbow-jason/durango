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

      alias Durango.Query

      def execute(%Query{} = q) do
        json = Query.to_json(q)
        Durango.Api.Cursors.create_cursor(__MODULE__, json)
      end

      def insert(item) do
        Durango.Repo.insert(__MODULE__, item)
      end

      def get(module, key) when is_atom(module) and is_binary(key) do
        Durango.Repo.get(__MODULE__, module, key)
      end

      def update(item) do
        Durango.Repo.update(__MODULE__, item)
      end

      def remove(item) do
        Durango.Repo.remove(__MODULE__, item)
      end

      def upsert(item) do
        Durango.Repo.upsert(__MODULE__, item)
      end

    end
  end

  alias Durango.Query
  require Durango

  def execute(repo, %Query{} = q) do
    json = Query.to_json(q)
    Durango.Api.Cursors.create_cursor(repo, json)
  end

  defp ensure_document!(%module{}, verb) do
    ensure_document!(module, verb)
  end
  defp ensure_document!(module, verb) do
    if not Durango.Document.is_document?(module) do
      raise ArgumentError, message: """
      Durango.Repo.#{verb}/1 only takes Durango.Document models.
      The model module #{inspect module} must `use Durango.Document` and define a document.
      """
    end
  end

  def insert(repo, doc) do
    ensure_document!(doc, :insert)
    q = insert_query(doc)
    execute(repo, q)
    |> into(doc)
  end

  def insert_query(%doc_collection{} = doc) do
    Durango.query([
      insert: ^doc,
      into: ^doc_collection,
      return: NEW,
    ])
  end

  def update(repo, doc) do
    ensure_document!(doc, :update)
    q = update_query(doc)
    execute(repo, q)
    |> into(doc)
  end

  def update_query(%doc_collection{} = doc) do
    Durango.query([
      let: this_doc = document(^doc._id),
      update: this_doc,
      with: ^doc,
      in: ^doc_collection,
      return: NEW,
    ])
  end

  def remove(repo, doc) do
    ensure_document!(doc, :remove)
    q = remove_query(doc)
    execute(repo, q)
    |> into(doc)
  end

  def remove_query(%doc_collection{} = doc) do
    Durango.query([
      let: item = document(^doc._id),
      remove: item,
      in: ^doc_collection,
      return: OLD,
    ])
  end

  def upsert(repo, doc) do
    ensure_document!(doc, :remove)
    repo
    |> execute(upsert_query(doc))
    |> into(doc)
  end

  def upsert_query(%doc_collection{} = doc) do
    doc_id = doc._id
    Durango.query([
      upsert: %{ _id: ^doc._id },
      insert: ^doc,
      update: ^doc,
      in: ^doc_collection,
      return: NEW,
    ])
  end

  def get(repo, module, key) when is_binary(key) and is_atom(module) do
    ensure_document!(module, :get)
    collection = module.__document__(:collection)
    collection_key = Path.join([to_string(collection), key])
    q = Durango.query([return: document(^collection_key)])
    execute(repo, q)
    |> into(module)
    |> case do
      [item]  -> item
      [nil]   -> nil
      nil     -> nil
    end
  end

  defp into(nil, _) do
    nil
  end
  defp into(data, module) when is_atom(module) and is_list(data) do
    data
    |> Enum.map(fn item -> into(item, module) end)
  end
  defp into(data, module) when is_atom(module) and is_map(data) do
    into(data, module.__struct__)
  end
  defp into({:ok, %{"result" => [nil] }}, _) do
    nil
  end
  defp into({:ok, %{"code" => code, "result" => data }}, model) when code in [200, 201, 202] do
    into(data, model)

  end
  defp into(data, models) when is_list(data) and is_list(models) and length(data) == length(models) do
    Enum.zip(data, models)
    |> Enum.map(fn {datum, model} -> into(datum, model) end)
  end
  defp into([data], %_{} = model) do
    into(data, model)
  end
  defp into(data = %{}, %_{} = model) do
    data
    |> GenUtil.Map.to_atom_keys
    |> Map.take(Map.keys(model))
    |> Enum.reduce(model, fn {key, value}, model_acc ->
      Map.put(model_acc, key, value)
    end)
  end
  defp into({:error, _} = err, _) do
    err
  end


end
