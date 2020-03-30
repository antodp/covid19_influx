defmodule Covid19Influx.MixProject do
  use Mix.Project

  def project do
    [
      app: :covid19_influx,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Covid19Influx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:httpoison, "~> 1.6"},
      {:broadway, "~> 0.6.0"},
      {:broadway_rabbitmq, "~> 0.6.0"},
      {:gen_rmq, "~> 2.5"},
      {:quantum, "~> 3.0-rc"},
      {:instream, "~> 0.22"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
