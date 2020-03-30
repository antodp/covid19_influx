defmodule Covid19Influx.ApplicationSettings do
    use GenServer

    @default_values [
        {"initial_date", Date.from_iso8601!("2020-01-22")}
    ]

    def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: __MODULE__)
    end

    def init(args) do
        {:ok, ref} = :dets.open_file(:app_settings, [{:type, :set}])
        
        put_default_values(ref)

        {:ok, %{dets_ref: ref}}
    end

    def get(key), do: GenServer.call __MODULE__, {:get, key}

    def put(key, value), do: GenServer.call __MODULE__, {:put, {key, value}}

    @impl true
    def handle_call({:get, key}, _from, state) do
        case :dets.lookup(state.dets_ref, key) do
            [] -> 
                {:reply, nil, state}
            [{_key, value}] ->
                {:reply, value, state}
        end
    end

    @impl true
    def handle_call({:put, kv}, _from, state) do
        :dets.insert(state.dets_ref, kv)
        {:reply, kv, state}
    end

    defp put_default_values(ref) do
        :dets.insert(ref, @default_values)
    end
end