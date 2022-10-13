defmodule Probe.Handler do
  use Agent

  def start_link(probes, opts \\ []) do
    path = samples_path(opts)
    File.rm_rf(path)

    path
    |> Path.dirname()
    |> File.mkdir_p!()

    # The agent is used to prevent race conditions when the handler is called
    # concurrently from multiple sources.
    {:ok, agent} = Agent.start_link(fn -> File.open!(path, [:write, :append]) end)

    probes
    |> Enum.map(fn probe -> probe.event_name() end)
    |> Enum.each(fn event_id ->
      :ok =
        :telemetry.attach(
          "probe.handler." <> Enum.join(event_id, "."),
          event_id,
          &__MODULE__.handle_event/4,
          %{agent: agent}
        )
    end)

    {:ok, agent}
  end

  def default_samples_path() do
    Path.join(["tmp", inspect(__MODULE__), "samples.jsonl"])
  end

  def export(probe, output_path, opts \\ []) do
    target_event = Enum.map(probe.event_name(), &Atom.to_string/1)

    opts
    |> samples_path()
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&Jason.decode!/1)
    |> Stream.filter(fn %{"event" => event} -> event == target_event end)
    |> Stream.map(&Map.delete(&1, "event"))
    |> Enum.into([])
    |> probe.compile(opts)
    |> VegaLite.Export.save!(output_path)
  end

  def handle_event(event, measurement, metadata, %{agent: pid}) do
    json =
      metadata
      |> Map.merge(measurement)
      |> Map.merge(%{event: event})
      |> Jason.encode!()

    Agent.get(pid, fn fd -> IO.write(fd, [json, ?\n]) end)
  end

  defp samples_path(opts) do
    Keyword.get(opts, :samples_path, default_samples_path())
  end
end
