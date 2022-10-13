defmodule System.Memory.Probe do
  use Probe
  use Task

  alias VegaLite, as: Vl

  def start_link(opts \\ []) do
    wait_ms = Keyword.get(opts, :poll_interval_ms, 1_000)
    {:ok, pid} = Task.start_link(__MODULE__, :run, [wait_ms])
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
    {reading, 0} = System.cmd("ps", ["-o", "vsz,rss", System.pid])
    parse_memory_measurement!(reading)
  end

  def run(wait_ms) do
    receive do
      :measure ->
        Probe.learn([:process, :memory, :probe], measure_memory!())
        Process.send_after(self(), :measure, wait_ms)
        run(wait_ms)
    end
  end

  @impl true
  def event_name(), do: [:process, :memory, :probe]

  @impl true
  def compile(data, _opts) do
    Vl.new(title: "Virtual Memory Size over time", height: 1080, width: 1920)
    |> Vl.data_from_values(data)
    |> Vl.mark(:line)
    |> Vl.encode_field(:x, "t", type: :quantitative)
    |> Vl.encode_field(:y, "vsz",
      type: :quantitative,
      scale: [zero: false],
      title: "Virtual Memory Size"
    )
  end
end
