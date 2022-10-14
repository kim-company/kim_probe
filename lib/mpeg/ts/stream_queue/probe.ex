defmodule MPEG.TS.StreamQueue.Probe do
  use Probe
  alias VegaLite, as: Vl

  @impl true
  def event_name(), do: [:mpeg_ts, :stream_queue, :probe]

  @impl true
  def compile(data, opts) do
    field = Keyword.get(opts, :field, "total_bytes")

    Vl.new(title: "Queue byte size over time", height: 1080, width: 1920)
    |> Vl.data_from_values(data)
    |> Vl.mark(:line)
    |> Vl.encode_field(:x, "t", type: :ordinal, time_unit: "hoursminutesseconds")
    |> Vl.encode_field(:color, "label", type: :nominal)
    |> Vl.encode_field(:y, field,
      type: :quantitative,
      scale: [zero: false]
    )
  end
end
