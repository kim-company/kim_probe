defmodule System.Memory.Probe do
  use Probe
  use Task

  alias VegaLite, as: Vl

  def start_link(period_ms \\ 1_000) do
    {:ok, pid} = Task.start_link(__MODULE__, :run, [period_ms])
    send(pid, :measure)

    {:ok, pid}
  end

  def parse_memory_measurement!(reading) do
    ~r/^.*\n\s*(?<vsz>\d+)\s*(?<rss>\d+).*$/
    |> Regex.named_captures(reading)
    |> Enum.map(fn {key, raw} -> {String.to_atom(key), String.to_integer(raw)} end)
    |> Enum.into(%{})
  end

  def measure_memory!() do
    {reading, 0} = System.cmd("ps", ["-o", "vsz,rss", System.pid()])
    parse_memory_measurement!(reading)
  end

  def run(period_ms) do
    receive do
      :measure ->
        Probe.learn([:system, :memory, :probe], measure_memory!())
        Process.send_after(self(), :measure, period_ms)
        run(period_ms)
    end
  end

  @impl true
  def event_name(), do: [:system, :memory, :probe]

  @impl true
  def compile(data, opts) do
    field = Keyword.get(opts, :field, "vsz")

    Vl.new(title: "Memory size over time", height: 1080, width: 1920)
    |> Vl.data_from_values(data)
    |> Vl.mark(:line)
    |> Vl.encode_field(:x, "t", type: :quantitative)
    |> Vl.encode_field(:y, field,
      type: :quantitative,
      scale: [zero: false]
    )
  end
end
