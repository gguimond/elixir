defmodule HTTPServer.Controller do
 def welcome(foo) when foo == "bar", do: Poison.encode!(%{response: "welcome mister " <> foo})
 def welcome(foo) when foo == "baz", do: Poison.encode!(%{response: "welcome miss " <> foo})
 def welcome(foo), do: Poison.encode!(%{response: "welcome ? " <> foo})
end
