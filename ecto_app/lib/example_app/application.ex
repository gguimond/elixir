defmodule EctoApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      ExampleApp.Repo
    ]

    opts = [strategy: :one_for_one, name: EctoApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end