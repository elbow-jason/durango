defmodule Durango.Mixfile do
  use Mix.Project

  def project do
    [
      app: :durango,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Durango.Application, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.0-rc"},
      {:httpoison, "~> 0.13"},
    ]
  end
end
