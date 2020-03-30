defmodule Covid19Influx.RMQPublisher do
    @behaviour GenRMQ.Publisher

    @rmq_uri "amqp://rabbitmq:rabbitmq@localhost:5672"
    @covid_exchange "covid_analytics"
    @covid_dates_queue "dates_queue"
    @covid_bulk_data_queue "bulk_data"
    @publish_options [persistent: false]

    def init do
        create_rmq_resources()

        [
            uri: @rmq_uri,
            exchange: @covid_exchange
        ]
    end

    def start_link do
        GenRMQ.Publisher.start_link(__MODULE__, name: __MODULE__)
    end

    def covid_dates_queue_size do
        GenRMQ.Publisher.message_count(__MODULE__, @covid_dates_queue)
    end
    
    def publish_dates(dates) do
        GenRMQ.Publisher.publish(__MODULE__, dates, @covid_dates_queue, @publish_options)
    end

    def publish_bulk_data(items) do
        GenRMQ.Publisher.publish(__MODULE__, items, @covid_bulk_data_queue, @publish_options)
    end

    def dates_queue_name, do: @covid_dates_queue

    def bulk_data_queue_name, do: @covid_bulk_data_queue

    defp create_rmq_resources do
        # Setup RabbitMQ connection
        {:ok, connection} = AMQP.Connection.open(@rmq_uri)
        {:ok, channel} = AMQP.Channel.open(connection)
    
        # Create exchange
        AMQP.Exchange.declare(channel, @covid_exchange, :topic, durable: true)
    
        # Create queues
        AMQP.Queue.declare(channel, @covid_dates_queue, durable: true)
        AMQP.Queue.declare(channel, @covid_bulk_data_queue, durable: true)
    
        # Bind queues to exchange
        AMQP.Queue.bind(channel, @covid_dates_queue, @covid_exchange, routing_key: @covid_dates_queue)
        AMQP.Queue.bind(channel, @covid_bulk_data_queue, @covid_exchange, routing_key: @covid_bulk_data_queue)
    
        # Close the channel as it is no longer needed
        # GenRMQ will manage its own channel
        AMQP.Channel.close(channel)
    end
end