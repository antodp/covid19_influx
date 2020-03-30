defmodule Covid19Influx.DateRangeGenerator do
    alias Covid19Influx.ApplicationSettings
    alias Covid19Influx.RMQPublisher

    def generate_dates do
        latest_fetched = get_latest_fetched()
        latest_date_api = get_latest_date_api()

        case Date.compare(latest_fetched, latest_date_api) do
            :lt ->
                {:ok, range} = split_and_publish_range(latest_fetched, latest_date_api)
                ApplicationSettings.put("latest_fetched", latest_date_api)
                
                {:ok, range}
            :eq ->
                {:ok, nil}

            _ ->
                {:error, nil}
        end
    end
    
    defp split_and_publish_range(start_date, end_date) do
        Date.range(start_date, end_date)
        |> Enum.chunk_every(5)
        |> Enum.each(&publish_range/1)

        {:ok, {start_date, end_date}}
    end

    defp publish_range(range) do
        %{start: List.first(range), end: List.last(range)}
        |> Jason.encode!()
        |> RMQPublisher.publish_dates
    end

    defp get_latest_fetched do
        case ApplicationSettings.get("latest_fetched") do
            nil ->
                ApplicationSettings.get("initial_date")
            date ->
                date
        end
    end

    defp get_latest_date_api do
        case Covid19Influx.Api.get_latest_date() do
            :error ->
                nil
            date ->
                date
                |> Date.from_iso8601!()
        end
    end
end