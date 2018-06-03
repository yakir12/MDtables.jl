__precompile__()
module MDtables

using StringBuilders

export printMD

fmtrfunc(x::String, s::Int) = x*" "^(s - length(x))

function printline!(o::T, x::Vector{String}, s::Int) where  {T<:StringBuilder}
    for c in x[1:end-1]
        append!(o, fmtrfunc(c, s))
        append!(o, " ")
    end
    append!(o, fmtrfunc(x[end], s))
    append!(o, "\n")
end

function printMD(a::Array)
    o = StringBuilder()
    nrow, ncol = size(a)
    b = [[string(a[r,c]) for c in 1:ncol] for r in 1:nrow]
    s = maximum(maximum(length, row) for row in b)
    printline!(o, b[1], s)
    printline!(o, fill("-"^s, ncol), s)
    if nrow > 1 
        for bi in b[2:end]
            printline!(o, bi, s)
        end
    end
    return String(o)
end

end
