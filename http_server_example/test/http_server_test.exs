defmodule HTTPServerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts HTTPServer.Router.init([])

  test "it returns index" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = HTTPServer.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "<h1>My beautif http server !!!</h1>"
  end

  test "it returns json" do
    # Create a test connection
    conn = conn(:post, "/", "{ \"params\" : { \"foo\" : \"bar\" } }") |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = HTTPServer.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "{\"response\":\"welcome mister bar\"}"
  end

end
