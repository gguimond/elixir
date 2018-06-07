defmodule SimpleQueue.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
    	worker(SimpleQueue, [[1, 2, 3]])
    ]
    opts = [strategy: :one_for_one, name: SimpleQueue.Supervisor]
    supervise(children, opts)
  end
end