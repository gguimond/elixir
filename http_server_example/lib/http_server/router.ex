defmodule HTTPServer.Router do
	use Plug.Router

  alias HTTPServer.Controller
  alias HTTPServer.DoRequest

  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :dispatch


	get "/" do
	    conn
	    |> put_resp_content_type("text/html")
	    |> send_resp(200, "<h1>My beautif http server !!!</h1>")
	end

  get "/crash" do
      throw "crash"
  end

  post "/" do
    {status, body} =
      case conn.body_params do
        %{"params" => params} -> {200, Controller.welcome Map.get(params, "foo")}
        _ -> {500, "Internal error"}
      end
    IO.inspect body
    send_resp(conn, status, body)
  end

  defp waitForResponse(conn) do
    receive do
      {:ok, response} -> 
        IO.inspect(response)
        send_resp(conn, 200, response)
      {:error, reason} ->
        IO.inspect(reason)
        send_resp(conn, 500, "error")
    end
  end

  get "/orange" do
    c = spawn(DoRequest, :init, [self(), nil])
    send c, {:geturl, "www.orange.fr"}
    waitForResponse(conn)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

end