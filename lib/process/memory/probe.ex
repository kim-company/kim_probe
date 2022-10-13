defmodule Process.Memory.Probe do
  use Probe
  use Task

  alias VegaLite, as: Vl

  def start_link(pid, opts \\ []) do
    period_ms = Keyword.get(opts, :period_ms, 1_000)
    {:ok, pid} = Task.start_link(__MODULE__, :run, [pid, period_ms])
    send(pid, :measure)

    {:ok, pid}
  end

  def measure_memory(pid) do
    case Process.info(pid, :binary) do
      {:binary, binaries} ->
        binaries
        |> Enum.map(fn {_ref, size, _ref_count} -> size end)
        |> Enum.count()
      _ ->
        0
    end
  end

  def run(pid, period_ms) do
    receive do
      :measure ->
        Probe.learn([:process, :memory, :probe], %{binary: measure_memory(pid)})
        Process.send_after(self(), :measure, period_ms)
        run(pid, period_ms)
    end
  end

  @impl true
  def event_name(), do: [:process, :memory, :probe]

  @impl true
  def compile(data, opts) do
    field = Keyword.get(opts, :field, "binary")

    Vl.new(title: "Process memory size over time", height: 1080, width: 1920)
    |> Vl.data_from_values(data)
    |> Vl.mark(:line)
    |> Vl.encode_field(:x, "t", type: :quantitative)
    |> Vl.encode_field(:y, field,
      type: :quantitative,
      scale: [zero: false]
    )
  end
end
