import Config

config :probe, :exportable, [
  {System.Memory.Probe, output_path: "probe.memory.html", opts: [field: "rss"]}
]
