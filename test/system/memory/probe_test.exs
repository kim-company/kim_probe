defmodule System.Memory.ProbeTest do
  use ExUnit.Case

  alias System.Memory.Probe

  test "parse_memory_measurement!/1" do
    assert %{vsz: 5431344, rss: 40444} == Probe.parse_memory_measurement!("     VSZ    RSS\n 5431344  40444\n")

    assert %{vsz: 2552740, rss: 69232} == Probe.parse_memory_measurement!("   VSZ   RSS\n2552740 69232\n")
  end

  test "measure_memory!/0" do
    assert %{} = Probe.measure_memory!()
  end
end
