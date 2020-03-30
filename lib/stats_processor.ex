defmodule Covid19Influx.StatsProcessor do
    use Broadway

    alias Broadway.Message
    alias Covid19Influx.{Timeserie, RMQPublisher, Connection}

    def start_link(_opts) do
        Broadway.start_link(__MODULE__,
            name: __MODULE__,
            producer: [
                module:
                    {BroadwayRabbitMQ.Producer,
                        queue: RMQPublisher.bulk_data_queue_name(),
                        connection: [
                            username: "rabbitmq",
                            password: "rabbitmq"
                    ]},
                concurrency: 1
            ],
            processors: [
                default: [concurrency: 5]
            ]
        )
      end

    def handle_message(_processor, %Message{data: data} = message, _context) do
        data
        |> Jason.decode!(keys: :atoms)
        |> Enum.each(&handle_item/1)
        
        message
    end

    defp handle_item(item) do
        item
        |> Map.get(:timeseries)
        |> Enum.map(&handle_stats/1)
        |> Connection.write(async: true)
    end

    defp handle_stats(stats) do
        Timeserie.from_map(%{
            country: "ITA",
            confirmed: stats.confirmed,
            deaths: stats.deaths,
            recovered: stats.recovered,
            timestamp: stats.time
        })
    end
    
end