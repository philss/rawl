defmodule Rawl.MixProject do
  use Mix.Project

  def project do
    [
      app: :rawl,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
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
      {:nimble_csv, "~> 0.6.0"}
    ]
  end
end
