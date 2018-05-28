defmodule Mix.Tasks.Example do
  use Mix.Task

  @shortdoc "Simply runs the Example.showHello/0 function"
  def run(_) do
    # calling our Example.showHello() function from earlier
    Example.showHello()
  end
end