defmodule Covid19InfluxTest do
  use ExUnit.Case
  doctest Covid19Influx

  test "greets the world" do
    assert Covid19Influx.hello() == :world
  end
end
