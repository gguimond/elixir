defmodule HTTPServer.DoRequest do

  defp getUrl(url) do
    proxy = {:http, "proxy.rd.francetelecom.fr", 8080, []}
    with {:ok, conn} <- Mint.HTTP.connect(:http, url, 80, proxy: proxy),
        {:ok, conn, _request_ref} <- Mint.HTTP.request(conn, "GET", "/", [], "") do
          {:ok, conn}
    else
      err -> err
    end
  end

  def init(pid, conn) do
    receive do
      {:geturl, url} -> 
        with {:ok, conn} <- getUrl url do
          init(pid, conn)
        else
           err -> send pid, err
        end
      message -> 
        case Mint.HTTP.stream(conn, message) do
          {:ok, conn, responses} -> send pid, {:ok, Enum.at(responses,2) |> elem(2)}
          err -> send pid, err
        end
        init(pid, nil)
    end
  end

end