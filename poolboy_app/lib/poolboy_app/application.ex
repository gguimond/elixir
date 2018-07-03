defmodule PoolBoy.Supervisor do
  use Supervisor

  defp poolboy_config do
    [
      {:name, {:local, :worker}},
      {:worker_module, PoolboyApp},
      {:size, 5},
      {:max_overflow, 2}
    ]
  end

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      worker(PoolBoy, [poolboy_config()])
    ]
    opts = [strategy: :one_for_one, name: PoolBoy.Supervisor]
    supervise(children, opts)
  end
end