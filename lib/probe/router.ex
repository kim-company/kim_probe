if Code.ensure_loaded?(Plug) do
  defmodule Probe.Router do
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    get "/:probe" do
      send_resp(conn, 200, "Render chart of #{probe}")
    end
  end
end
