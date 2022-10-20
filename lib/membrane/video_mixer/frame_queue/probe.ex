defmodule VideoMixer.FrameQueue.Probe do
  use Probe
  alias VegaLite, as: Vl

  @impl true
  def event_name(), do: [:video_mixer, :frame_queue]

  @impl true
  def compile(data, opts) do
    field = Keyword.get(opts, :field, "count")

    Vl.new(title: "Number of items the queue over time", height: 1080, width: 1920)
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
