defmodule Example.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/probe", to: Probe.Router

  match _ do
    send_resp(conn, 404, "oops")
  end
end
