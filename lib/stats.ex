defmodule Covid19Influx.Stats do
    alias __MODULE__

    defstruct confirmed: nil,
              deaths: nil,
              recovered: nil,
              time: nil

    def create_from_response(response) do
        with confirmed <- Map.get(response, "confirmed"),
             date      <- Map.get(response, "date"),
             deaths    <- Map.get(response, "deaths"),
             recovered <- Map.get(response, "recovered") do
            
            create(confirmed, deaths, recovered, date)
        
        end
        
    end

    def create(confirmed, deaths, recovered, date) do
        %Stats{
            confirmed: confirmed,
            deaths: deaths,
            recovered: recovered,
            time: get_time_iso8601(date, :nanosecond)
        }
    end

    def get_time_iso8601(nil, _), do: nil
    def get_time_iso8601(time, unit) do
        {:ok, datetime, _} = "#{time}T00:00:00Z" |> DateTime.from_iso8601()
        DateTime.to_unix(datetime, unit)
    end
end