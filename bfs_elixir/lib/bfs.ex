#BFS
defmodule Bfs do
    defp neighbors(graph, v) do
        {Map.get(graph, v, MapSet.new), v}
    end

    defp find_path(_, from, to, path) when from == to, do: path
    defp find_path(prev, from, to, path) when from != to, do: find_path(prev, from, Map.get(prev, to), [Map.get(prev, to) | path])

    @doc """
        Given graph and 2 points, return the distance and shortest path.

        ## Example
            iex> graph = %{"0" => MapSet.new(["2"]),"1" => MapSet.new(["1"]),"2" => MapSet.new(["0", "3", "4"]),"3" => MapSet.new(["2", "4"]),"4" => MapSet.new(["2", "3", "6"]),"5" => MapSet.new(["6"]),"6" => MapSet.new(["4", "5"])}
            iex> Bfs.shortest_path!(graph, "0", "0")
            {0, ["0"]}
            iex> Bfs.shortest_path!(graph, "0", "6")
            {3, ["0", "2", "4", "6"]}
            iex> Bfs.shortest_path!(graph, "3", "6")
            {2, ["3", "4", "6"]}
            iex> Bfs.shortest_path!(graph, "6", "3")
            {2, ["6", "4", "3"]}
    """

    def shortest_path!(graph, from, to) when from != to, do: shortest_path(graph, from, [from], MapSet.new , to, 0, %{})
    def shortest_path!(_, from, to) when from == to, do: {0, [from]}

    defp shortest_path(_, _, [], _, _, _, _) do
        throw "NOT FOUND"
    end

    defp shortest_path(graph, from, frontier, seen, to, dist, prev) do
        result = for v <- frontier do
            neighbors(graph, v)
        end
        unseen_neighbors = result
        |> Enum.map(fn x -> x |> elem(0) end)
        |> Enum.reduce(MapSet.new, &MapSet.union/2)
        |> MapSet.difference(seen)

        newdist = dist + 1
        newprev = result
        |> Enum.reduce(prev, fn x, acc -> Map.merge( 
            Enum.reduce(x |> elem(0), %{}, fn (y, acc) -> 
                cond do
                    MapSet.member?(unseen_neighbors, y) -> Map.put(acc, y, x |> elem(1))
                    true -> acc
                end
            end
        ), acc) end)
        
        case MapSet.member?(unseen_neighbors, to) do 
            true-> {newdist, find_path(newprev, from, to, [to])}
            false-> shortest_path(
                        graph,
                        from,
                        MapSet.to_list(unseen_neighbors),
                        MapSet.union(seen, MapSet.new(unseen_neighbors)),
                        to,
                        newdist,
                        newprev
                    )
        end 
    end
end

"""
graph = %{
    "0" => MapSet.new(["2"]),
    "1" => MapSet.new(["1"]),
    "2" => MapSet.new(["0", "3", "4"]),
    "3" => MapSet.new(["2", "4"]),
    "4" => MapSet.new(["2", "3", "6"]),
    "5" => MapSet.new(["6"]),
    "6" => MapSet.new(["4", "5"])
}

IO.inspect "Graph"
IO.inspect graph

IO.inspect "0 -> 0"
IO.inspect Bfs.shortest_path!(graph, "0", "0")

IO.inspect "0 -> 6"
IO.inspect Bfs.shortest_path!(graph, "0", "6")

IO.inspect "3 -> 6"
IO.inspect Bfs.shortest_path!(graph, "3", "6")

IO.inspect "6 -> 3"
IO.inspect Bfs.shortest_path!(graph, "6", "3")

IO.inspect "7 -> 5"
IO.inspect Bfs.shortest_path!(graph, "7", "5")

IO.inspect "5 -> 7"
IO.inspect Bfs.shortest_path!(graph, "5", "7")
"""