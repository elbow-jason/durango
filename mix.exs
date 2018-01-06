defmodule Durango.Mixfile do
  use Mix.Project

  def project do
    [
      app: :durango,
      version: "0.1.0-a",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Durango",
      source_url: "https://github.com/elbow-jason/durango",
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
      {:gen_util, "~> 0.1.0"},
      {:ex_doc, "~> 0.14", only: :dev},
    ]
  end

  defp description() do
    "A database wrapper for ArangoDB"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "durango",
      # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jason Goldberger"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/elbow-jason/durango"}
    ]
  end
end
