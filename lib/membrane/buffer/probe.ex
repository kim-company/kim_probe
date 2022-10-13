defmodule Membrane.Buffer.Probe do
  use Membrane.Filter
  use Probe

  alias VegaLite, as: Vl

  def_input_pad(:input,
    demand_unit: :buffers,
    caps: :any
  )

  def_output_pad(:output,
    demand_unit: :buffers,
    caps: :any
  )

  def_options(
    label: [
      spec: String.t(),
      description: "Label forwarded in the metadata field of each telemetry event",
      default: __MODULE__
    ]
  )

  @impl true
  def handle_init(opts) do
    {:ok, opts.label}
  end

  @impl true
  def handle_demand(_pad, size, :buffers, _context, label) do
    {{:ok, demand: {:input, size}}, label}
  end

  @impl true
  def handle_process(_pad, buffer = %Membrane.Buffer{pts: pts, dts: dts}, _ctx, label) do
    Probe.learn([:membrane, :buffer], %{pts: pts, dts: dts}, %{label: label})
    {{:ok, forward: buffer, demand: :input}, label}
  end

  @impl true
  def event_name(), do: [:membrane, :buffer]

  @impl true
  def compile(data, opts) do
    data =
      Enum.map(
        data,
        &Map.update!(&1, :t, fn old -> :erlang.convert_time_unit(old, :native, :microsecond) end)
      )

    field = Keyword.get(opts, :field, "pts")

    Vl.new(title: "Buffer #{String.upcase(field)} over time", height: 1080, width: 1920)
    |> Vl.data_from_values(data)
    |> Vl.mark(:line)
    |> Vl.encode_field(:x, "t", type: :quantitative)
    |> Vl.encode_field(:y, field,
      type: :quantitative,
      scale: [zero: false],
      title: "#{field} (ms)",
      axis: [label_expr: "datum.value / 1000000000"]
    )
    |> Vl.encode_field(:color, "label", type: :nominal)
  end
end
