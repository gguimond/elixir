[run Elixir online](https://www.jdoodle.com/execute-elixir-online)  
[link to pres](https://hackmd.io/sr3Z4z3eRPapB96IXkw1ag)

# Introduction to Elixir
----
## Erlang VM based (BEAM)
* Erlang =< Facebook, WhatsApp, Amazon, Heroku, Ericsson ...
* Low latency, concurrency
* Actor Model : actor = unit of computation, has mailbox, gets messages and computes accordingly. Data isolated.
* Fault tolerance : let it crash, supervised. 
* Supervisor pattern, supervision tree : one process to run the process and another to supervise the process. Actor = process, supervisor = actor = process. Most common strategy : restart process with initial state
* hot reloading
* OTP, ERTS
* Distribution : local or network nodes

## Elixir overview
* José Valim in 2012
* Erlang bytecode
* Documentation and tools
* Functional : immutable state, purity, functions as first-class object (composition), high-order function, recursive iteration instead of looping (avoid side effect, tail call optimization)

## Language
### types
* Integer, Float, Ranges, Atoms, Regex
* Tuples, Linked List, Binaries, Maps 
```elixir
name = "Sean"
string = " Hello " <> name
list = ([1, 2] ++ [3, 4]) -- [1,3]
tuple = {3.14, :pie, "Apple"}
keywordlist = [{:foo, "bar"}, {:hello, "world"}]
map = %{:foo => "bar", "hello" => :world}
map2 = %{map | foo: "baz"}
IO.puts :stderr, map2.foo
```
* Enum
```elixir
IO.puts Enum.all?(["foo", "bar", "hello"], fn(s) -> String.length(s) == 3 end)
IO.puts Enum.chunk_by(["one", "two", "three", "four", "five"], fn(x) -> String.length(x) end)
IO.puts Enum.map([0, 1, 2, 3], fn(x) -> Integer.to_string(x - 1) end)
IO.puts Enum.filter([1, 2, 3, 4], fn(x) -> rem(x, 2) == 0 end)
IO.puts Enum.reduce(["a","b","c"], "1", fn(x,acc)-> x <> acc end)
```
* Struct
```elixir
defmodule User do
  defstruct name: "John", age: 27
end

defmodule Main do
  def main do
    IO.inspect %User{}
    bar = %User{name: "foo"}
    IO.inspect bar.name
    IO.inspect %{bar | age: 18}
  end
end
Main.main
```
### Anonymous function, named function
```elixir
defmodule Greeter do
  def hello(name), do: phrase() <> name
  defp phrase do
      "Hello, "
  end
end

sum = fn (a, b) -> a + b end
sum2 = &(&1 + &2)
IO.puts Integer.to_string sum.(2,3)
IO.puts Integer.to_string sum2.(2,3)

```
### Pattern Matching (assignment vs binding)
```elixir
list = [1, 2, 3, "test"]
[1, 2, 3 | tail] = list
IO.puts tail

greet = fn
  ("Hello", name) -> "Hi #{name}"
  (greeting, name) -> "#{greeting}, #{name}"
end
IO.puts greet.("Hello", "Sean")
IO.puts greet.("Mornin'", "Sean")
```
### Guards
```elixir
defmodule Guards do
  def empty_map?(map) when map_size(map) == 0, do: true
  def empty_map?(map) when is_map(map), do: false
end

defmodule Main do
  def main(x) do
      case x do
          1 -> :one
          2 -> :two
          n when is_integer(n) and n > 2 -> :larger_than_two
      end
  end
end
```
### Control structures
```elixir
defmodule Main do
  def main do
    if String.valid?("Hello") do
      IO.puts "ok"
    else
      IO.puts "ko"
    end

    case {:ok, "Hello World"} do
      {:ok, result} -> IO.puts result
      {:error} -> IO.puts "Uh oh!"
      _ -> IO.puts "Catch all"
    end

    cond do
      7 + 1 == 0 -> IO.puts "Incorrect"
      true -> IO.puts "Catch all"
    end

    user = %{first: "doomspork", last: "Callan"}
    with {:ok, first} <- Map.fetch(user, :first),
      {:ok, last} <- Map.fetch(user, :last),
      do: IO.puts last <> ", " <> first
  end
end
Main.main
```
### Pipe
```elixir
IO.inspect "Elixir rocks" 
  |> String.upcase
  |> String.split
```
### List comprehensions
```elixir
list = [1, 2, 3, 4, 5]
for x <- list, do: IO.puts x*x

for {k, v} <- %{"a" => "A", "b" => "B"}, do: IO.puts k

for n <- list, times <- 1..n do
    IO.puts String.duplicate("*", times)
end

import Integer
for x <- 1..10, is_even(x), do: IO.puts x

for {k, v} <- [one: 1, two: 2, three: 3], into: %{}, do: {k, v}
```
### Macros (Ex if), Meta programming
```elixir
defmodule OurMacro do
  defmacro unless(expr, do: block) do
    quote do
      if !unquote(expr), do: unquote(block)
    end
  end
  defmacro hygienic do
    quote do: val = -1
  end
  defmacro unhygienic do
    quote do: var!(val) = -1
  end
  defmacro double_puts(expr) do
    quote bind_quoted: [expr: expr] do
      IO.puts(expr)
      IO.puts(expr)
    end
  end
end

defmodule Main do
    require OurMacro
  def main do
    OurMacro.unless false, do: IO.puts "Hi hi hi"
  end
end

Main.main
```
### Errors
```elixir
case my_function() do
  {:ok, any} ->
    Logger.info(“Success”)
    {:ok, any}
 
  {:error, error} ->
    Logger.error(“Error: #{error}”)
    {:error, :bad}
end
```
### Exceptions
```elixir
defmodule MyError do
  defexception message: "an example error has occurred"
end


defmodule Main do
  def main do
    try do
      raise MyError
    rescue
      e in MyError -> IO.puts("An error occurred: " <> e.message)
      e in RuntimeError -> IO.puts("An error occurred: " <> e.message)
     end
    after
    IO.puts "finish"
    
  try do
      for x <- 0..10 do
      if x == 5, do: throw(x)
        IO.puts(x)
      end
    catch
      x -> IO.puts "Caught: #{x}"
    end
  end
end

Main.main
```
### Custom types & Behaviours
```elixir
defmodule Main do
  @type my_type :: {number, String.t}

  @spec my_func(number) :: my_type
  def my_func(x), do: {x, "why always me ?"}
end
IO.inspect Main.my_func 7

defmodule Mymodule do
  @callback mandatory(String.t) :: {:ok}
end

defmodule Mymodule_implem do
  @behaviour Mymodule
  
  def mandatory(x) do
    IO.puts x
    {:ok}
  end
end
Mymodule_implem.mandatory "foo"
```
### Documentation/DocTests
```elixir
defmodule Main do
  @moduledoc """
    Provides a main function
    """
    
  @doc """
    Main function

    ## Parameters

      - none

    ## Examples

        iex> Main.main()
        "foo bar"
    """
  def main do
    IO.puts "foo bar"
  end
end
Main.main

defmodule MainTest do
  use ExUnit.Case, async: true
  doctest Main
end
```
### Test/ ExUnit
```elixir
defmodule MainTest do
  use ExUnit.Case

  test "foo bar" do
    assert Main.main() == "foo bar"
  end
end
```
### Debug
IEX, IO.inspect, IEx.pry, IEx.break, :debugger


## Tools
### Mix
> Mix is a build tool that ships with Elixir that provides tasks for creating, compiling, testing your application, managing its dependencies and much more
* Creation
```console
mix new example --module Example

* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating config
* creating config/config.exs
* creating lib
* creating lib/example.ex
* creating test
* creating test/test_helper.exs
* creating test/example_test.exs
```
* Mix.exs
```elixir
defmodule Example.Mixfile do
  use Mix.Project

  def project do
    [app: :example,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end
end
```
* Dependencies / Hex package manager
```console
mix deps.get
```
* Compilation
```console
mix compile
```
* Run
```console
mix run --no-halt
```
* Test
```console
mix test
```
* Code formatting
```console
mix format
```
### Distillery
> a tool for packaging Elixir applications for deployment using OTP releases
> produces an artifact, a tarball, which contains your application and everything needed to run it
* Mix tasks
```console
mix release.init
mix release
```
* Release tasks / entry point bin/myapp
```console
foreground 
console
start
stop
```
## HTTP/Web
### Authentication/Guardian
### Cowboy
> Small, fast, modern HTTP server for Erlang/OTP
### Plug
* A specification for composable modules between web applications
* Connection adapters for different web servers in the Erlang VM
```elixir
defmodule Example.HelloWorldPlug do
  import Plug.Conn

   def init(options), do: options

   def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello World!\n")
  end
end 
```
```elixir
defmodule Example.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias Example.Plug.VerifyRequest

  plug(Plug.Parsers, parsers: [:urlencoded, :multipart])

  plug(
    VerifyRequest,
    fields: ["content", "mimetype"],
    paths: ["/upload"]
  )

  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Welcome"))
  post("/upload", do: send_resp(conn, 201, "Uploaded\n"))
  match(_, do: send_resp(conn, 404, "Oops!"))
end 
```
### Templates EEX
```elixir
IO.puts EEx.eval_string("Hi, <%= @name %>", [assigns: [name: "Kante"]])
```
### Phoenix
> web development framework written in Elixir which implements the server-side Model View Controller (MVC) pattern (Rails, Django)
## DB
* ETS
* Mnesia
* Ecto

## Perf
* low latency, concurrency, footprint
* computation
* Concurrency : “light threads” or “green threads”, scheduler, preemptive (vs cooperative), messages queues (spawn and send/receive functions)
>"Elixir processes have their own isolated heap spaces which are individually reclaimed when the process finishes, while goroutines utilize shared memory and an application-wide garbage collector to reclaim resources"
```elixir
defmodule ExConc do
  def listen do
    receive do
      {:ok, "hello"} -> IO.puts("World")
    end
    listen
  end
end
pid = spawn(ExConc, :listen, [])
send pid, {:ok, "hello"}
pid2 = spawn_link(ExConc, :listen, [])
send pid2, {:ok, "hello"}
{pid3, ref} = spawn_monitor(ExConc, :listen, [])
send pid3, {:ok, "hello"}
```
* Tasks
```elixir
defmodule Example do
  def double(x) do
    :timer.sleep(2000)
    x * 2
  end
end
task = Task.async(Example, :double, [2000])
IO.puts Task.await(task)
```
* GenServer (& Agent)
> A behaviour module for implementing the server of a client-server relation
```elixir
defmodule SimpleQueue do
  use GenServer

  @doc """
    Start our queue and link it.  This is a helper function
    """

    def start_link(state \\ []) do
      GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    @doc """
  GenServer.init/1 callback
  """

  def init(state), do: {:ok,state}

  @doc """
  GenServer.handle_call/3 callback
  """
  def handle_call(:dequeue, _from, [value | state]) do
    {:reply, value, state}
  end

  def handle_call(:dequeue, _from, []), do: {:reply, nil, []}

  def handle_call(:queue, _from, state), do: {:reply, state, state}

  @doc """
  GenServer.handle_cast/2 callback
  """
  def handle_cast({:enqueue, value}, state) do
    {:noreply, state ++ [value]}
  end


  def queue, do: GenServer.call(__MODULE__, :queue)
  def dequeue, do: GenServer.call(__MODULE__, :dequeue)
  def enqueue(value), do: GenServer.cast(__MODULE__, {:enqueue, value})
end
SimpleQueue.start_link([1, 2, 3])
IO.inspect SimpleQueue.enqueue(20)
IO.inspect SimpleQueue.queue
IO.inspect SimpleQueue.dequeue
```
* Supervisor
> A supervisor is a process whose responsibility is to start child processes and keep them alive by restarting them if necessary
```elixir
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
```
* GenStage
> specification and computational flow for Elixir
> provides a way to define a pipeline of work to be carried out by independent steps (or stages) in a separate processes
[A] -> [B] -> [C]
* Poolboy
> lightweight, generic pooling library that limits the maximum number of concurrent processes that your program can spawn
* Benchee
> Easy and extensible benchmarking in Elixir providing you with lots of statistics!

## BFS algo example
https://github.com/gguimond/elixir/blob/d1998700548039a891eabc7dbcfe3d8998fbf2ad/bfs_elixir/lib/bfs.ex

## B2w bank stub
