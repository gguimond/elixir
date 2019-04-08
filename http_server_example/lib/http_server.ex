defmodule HTTPServer.Application do
 use Application
 require Logger
 def start(_type, _args) do
    port = Application.get_env(:http_server, :cowboy_port, 8099)
    children = [
      {Plug.Adapters.Cowboy2,
        scheme: :http,
        plug: HTTPServer.Router,
        options: [port: port]
      }
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
