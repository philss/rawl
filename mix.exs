defmodule Rawl.MixProject do
  use Mix.Project

  def project do
    [
      app: :rawl,
      version: "0.1.0",
      elixir: "~> 1.9",
      name: "Rawl",
      source_url: "https://github.com/philss/rawl",
      start_permanent: Mix.env() == :prod,
      docs: [
        extras: ["README.md"]
      ],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:norm, "~> 0.7.1"},
      {:nimble_csv, "~> 0.6.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:stream_data, "~> 0.4", only: [:dev, :test]}
    ]
  end
end
