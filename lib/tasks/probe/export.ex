defmodule Mix.Tasks.Probe.Export do
  @moduledoc "Export probe samples as compiled VegaLite graphics"
  @shortdoc "Exports probes to VegaLite"

  use Mix.Task

  @requirements ["app.config"]

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:vega_lite)

    :probe
    |> Application.fetch_env!(:exportable)
    |> Enum.each(fn {probe, config} ->
      [output_path, opts] = Enum.map([:output_path, :opts], fn key -> Keyword.fetch!(config, key) end)
      Probe.Handler.export(probe, output_path, opts)
    end)
  end
end
