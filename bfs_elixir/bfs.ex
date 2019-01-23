#Fifo

newFifo = fn -> {[], []} end

pushFifo = fn({l,r},x) -> {l,[x|r]} end

popFifo = fn 
        {[f|l],r} -> {f, {l,r}} 
        {[], r} -> 
            case :lists.reverse(r) do 
                []->throw "BLARGH-EMPTY"
                [f|l]->{f, {l,[]}} 
            end 
        end

fifo = newFifo.()
f1 = fifo    |> pushFifo.(1) 
        |> pushFifo.(2)
        |> pushFifo.(3)
f2 = f1 |> popFifo.()
IO.inspect f2
IO.inspect f2 |> elem(1) |> popFifo.()


#BFS
defmodule Bfs do
    defp neighbors(graph, v) do
        Map.get(graph, v, MapSet.new)
    end

    def bfs(_, [], seen) do
        seen
    end

    def bfs(graph, frontier, seen) do
        unseen_neighbors = for v <- frontier do
          neighbors(graph, v)
        end
        |> Enum.reduce(MapSet.new, &MapSet.union/2)
        |> MapSet.difference(seen)
        |> MapSet.to_list

        bfs(
          graph,
          unseen_neighbors,
          MapSet.union(seen, MapSet.new(unseen_neighbors))
        )
    end

    def shortest_path(_, [], _, _, dist) do
        throw "NOT FOUND"
    end

    def shortest_path(graph, frontier, seen, to, dist) do
        unseen_neighbors = for v <- frontier do
          neighbors(graph, v)
        end
        |> Enum.reduce(MapSet.new, &MapSet.union/2)
        |> MapSet.difference(seen)

        newdist = dist + 1

        case MapSet.member?(unseen_neighbors, to) do 
                true-> newdist
                false-> shortest_path(
                          graph,
                          MapSet.to_list(unseen_neighbors),
                          MapSet.union(seen, MapSet.new(unseen_neighbors)),
                          to,
                          newdist
                        )
            end 
    end
end

graph = %{
    "0" => MapSet.new(["2"]),
    "1" => MapSet.new(["1"]),
    "2" => MapSet.new(["0", "3", "4"]),
    "3" => MapSet.new(["2", "4"]),
    "4" => MapSet.new(["2", "3", "6"]),
    "5" => MapSet.new(["6"]),
    "6" => MapSet.new(["4", "5"])
}
IO.inspect graph
IO.inspect Bfs.bfs(graph,["0"],MapSet.new)

IO.inspect Bfs.shortest_path(graph, ["0"], MapSet.new , "6", 0)
IO.inspect Bfs.shortest_path(graph, ["5"], MapSet.new , "0", 0)
IO.inspect Bfs.shortest_path(graph, ["5"], MapSet.new , "7", 0)