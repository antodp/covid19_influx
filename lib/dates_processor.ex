defmodule Covid19Influx.DatesProcessor do
    use Broadway
  
    alias Broadway.Message
    alias Covid19Influx.{Api, RMQPublisher}
  
    def start_link(_opts) do
        Broadway.start_link(__MODULE__,
            name: __MODULE__,
            producer: [
                module: {BroadwayRabbitMQ.Producer,
                            queue: RMQPublisher.dates_queue_name(),
                            connection: [
                                username: "rabbitmq",
                                password: "rabbitmq"
                        ]},
                concurrency: 1
            ],
            processors: [
                default: [concurrency: 5]
            ],
            batchers: [
                batcher_1: [concurrency: 2, batch_size: 2, batch_timeout: 10_000]
            ]
        )
    end
  
    @impl true
    def handle_message(_processor, message, _context) do
        message
        |> Message.update_data(&process_date_range/1)
        |> Message.put_batcher(:batcher_1)
    end
  
    @impl true
    def handle_batch(_batcher, messages, _batch_info, _context) do
        encoded_payload =
            messages
            |>  Enum.reject(fn
                    %Message{data: {_, :error}} -> true
                    _ -> false
                end)
            |>  Enum.map(fn %Message{data: {{starting, ending}, stats}} ->
                    %{
                        period: %{start: starting, end: ending},
                        timeseries: Enum.map(stats, &Map.from_struct/1)
                    }
                end)
            |>  Jason.encode!()
  
        RMQPublisher.publish_bulk_data(encoded_payload)
  
        messages
    end

    defp process_date_range(date_range) do
        %{start: starting, end: ending} = Jason.decode!(date_range, keys: :atoms)
        {{starting, ending}, Api.get_timeseries(starting, ending)}
    end
  end