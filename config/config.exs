use Mix.Config

config :covid19_influx, Covid19Influx.Connection,
    database: "db0",
    auth: [ method: :basic, 
            username: "admin", 
            password: "admin" ]

config :covid19_influx, Covid19Influx.Scheduler,
    jobs: [
        {"@daily", {Covid19Influx.DateRangeGenerator, :generate_dates, []}}
    ]