defmodule PoolBoy do
  use GenServer

  def start_link(state \\ []) do
      GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

  def start(_type, _args) do
    PoolBoy.Supervisor.start_link([])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:square_root, x}, _from, state) do
    IO.puts("process #{inspect(self())} calculating square root of #{x}")
    :timer.sleep(1000)
    {:reply, :math.sqrt(x), state}
  end
end