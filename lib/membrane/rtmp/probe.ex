defmodule Membrane.RTMP.Probe do
  use Probe

  alias VegaLite, as: Vl

  @impl true
  def event_name(), do: [:membrane, :rtmp, :write_frame]

  @impl true
  def compile(data, opts) do
    field = Keyword.get(opts, :field, "ts")

    Vl.new(title: "Buffer #{String.upcase(field)} over time", height: 1080, width: 1920)
    |> Vl.data_from_values(data)
    |> Vl.mark(:line)
    |> Vl.encode_field(:x, "t", type: :ordinal)
    |> Vl.encode_field(:y, field,
      type: :quantitative,
      scale: [zero: false],
      title: "#{field} (ms)",
      axis: [label_expr: "datum.value / 1000000000"]
    )
  end
end
