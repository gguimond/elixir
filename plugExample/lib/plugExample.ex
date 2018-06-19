defmodule Example do
  use Application
  require Logger

  def start(_type, _args) do
  	import Supervisor.Spec
  	port = Application.get_env(:plugExample, :cowboy_port)
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Example.Router, [], port: port)
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end