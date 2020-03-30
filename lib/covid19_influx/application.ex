defmodule Covid19Influx.Application do
  use Application

  def start(_type, _args) do
    children = [
      Covid19Influx.ApplicationSettings,
      Covid19Influx.Scheduler,
      Covid19Influx.Connection,
      Covid19Influx.DatesProcessor,
      Covid19Influx.StatsProcessor,
      
      :hackney_pool.child_spec(:covid_pool_id, timeout: 15000, max_connections: 100),
      
      %{
        id: Covid19Influx.RMQPublisher,
        start: {Covid19Influx.RMQPublisher, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: Covid19Influx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
