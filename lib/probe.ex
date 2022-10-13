defmodule Probe do
  @type t :: module()
  @type event_name_t :: :telemetry.event_name()
  @type graph_spec_t :: VegaLite.t()

  @callback event_name() :: event_name_t()
  @callback compile(values :: [any()], opts :: Keyword.t()) :: graph_spec_t() | no_return()

  defmacro __using__(_) do
    quote do
      @behaviour Probe
    end
  end
end
