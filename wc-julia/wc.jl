#!/usr/bin/env julia

using Printf

function wc(dir)
    files = filter(isfile, joinpath.(dir, readdir(dir)))
    results = asyncmap(files) do f
        open(f) do io
            (lines=countlines(io),filename=f)
        end
    end
    sort!(results, by = x -> x[:lines], rev=true)
    for r in results
        @printf("%10i %s\n", r[:lines], r[:filename])
    end
    total_lines = mapreduce(x -> x[:lines], +, results)
    @printf("%10i %s\n", total_lines, "[TOTAL]")
end

wc(get(ARGS,1,"."))
