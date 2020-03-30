defmodule Covid19Influx.Api do
    require Logger

    alias Covid19Influx.Stats

    def get_timeseries(starting, ending) do
        get_timeseries(starting, ending, 4)
    end

    def get_latest_date do
        get_latest_date 4
    end

    defp get_timeseries(starting, ending, retry) when retry > 0 do
        response =
            {starting, ending}
            |> range_url()
            |> request()
        
        with {:ok, body}          <- handle_response(response),
             {:ok, decoded}       <- Jason.decode(body, key: :atoms),
             {:ok, timeseries}    <- parse_into_stats(decoded) do
                timeseries
        else
             {:error, reason} ->
                Logger.warn("Failed fetching resource: #{inspect reason}")
                get_timeseries(starting, ending, retry - 1)
        end
    end

    defp get_timeseries(_starting, _ending, retry) when retry <= 0 do 
        :error
    end

    defp get_latest_date(retry) when retry > 0 do
        response =
            latest_date_url()
            |> request()
        
        with {:ok, date} <- handle_response(response) do
            date
        else
            {:error, reason} ->
                Logger.warn("Failed fetching resource: #{inspect reason}")
                get_latest_date(retry - 1)
        end
    end

    defp get_latest_date(retry) when retry <= 0, do: :error

    defp parse_into_stats(decoded_data) do
        parsed = decoded_data
                 |> Map.get("result")
                 |> Enum.map(&Stats.create_from_response/1)
        {:ok, parsed}
    end

    defp request(url) do
        url
        |> HTTPoison.get([], hackney: [pool: :covid_pool_id])
    end

    defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
        {:ok, body}
    end

    defp handle_response({_, invalid_response}) do
        {:error, invalid_response}
    end

    defp range_url({starting, ending}) do
        "https://covidapi.info/api/v1/country/ITA/timeseries/"
        |> URI.merge("#{starting}/#{ending}")
        |> URI.to_string()
    end

    defp latest_date_url do
        "https://covidapi.info/api/v1/latest-date"
    end
end