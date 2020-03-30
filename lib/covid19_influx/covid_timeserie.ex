defmodule Covid19Influx.Timeserie do
    use Instream.Series

    series do
        database "db0"
        measurement "census"

        tag :country

        field :confirmed
        field :deaths
        field :recovered
    end
end