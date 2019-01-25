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
defmodule BfsOld do
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

    defp neighbors_and_prev(graph, v) do
        { Map.get(graph, v, MapSet.new), v }
    end

    defp find_path(prev, from, to, path) do
        cond do
            from == to -> path
            true -> find_path(prev, from, Map.get(prev, to), [ Map.get(prev, to) | path ])
        end
    end

    def shortest_path(_, _, [], _, _, _, _) do
        throw "NOT FOUND"
    end

    def shortest_path(graph, from, frontier, seen, to, dist, prev) do
        result = for v <- frontier do
          neighbors_and_prev(graph, v)
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
                true-> { newdist, find_path(newprev, from, to, [to]) }
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
IO.inspect graph
IO.inspect BfsOld.bfs(graph,["0"],MapSet.new)

IO.inspect BfsOld.shortest_path(graph, "0", ["0"], MapSet.new , "6", 0, %{})
IO.inspect BfsOld.shortest_path(graph, "3", ["3"], MapSet.new , "6", 0, %{})
IO.inspect BfsOld.shortest_path(graph, "6", ["6"], MapSet.new , "3", 0, %{})
IO.inspect BfsOld.shortest_path(graph, "5", ["5"], MapSet.new , "7", 0, %{})
"""