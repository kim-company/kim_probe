defmodule Probe.MixProject do
  use Mix.Project

  def project do
    [
      app: :probe,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:membrane_core, "~> 0.10.2"},
      {:telemetry, "~> 1.1"},
      {:jason, "~> 1.4"},
      {:vega_lite, "~> 0.1.6"},
      {:plug, "~> 1.13", optional: true}
    ]
  end
end
