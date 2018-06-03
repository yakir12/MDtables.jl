__precompile__()
module MDtables

using StringBuilders

import Base:print

export SimpleTable, MultilineTable, GridTable, print

abstract type MDtable end

struct SimpleTable{T<:StringBuilder} <: MDtable
    o::T
end

struct MultilineTable{T<:StringBuilder} <: MDtable
    o::T
end

struct GridTable{T<:StringBuilder} <: MDtable
    o::T
end

function printline!(o, columns, widths, delimiter)
    for (c, w) in zip(columns, widths)
        append!(o.o, delimiter)
        append!(o.o, rpad(c, w))
    end
    append!(o.o, delimiter)
    append!(o.o, "\n")
end

topbottom(o::SimpleTable{<:StringBuilder}, widths) = nothing
topbottom(o::GridTable{<:StringBuilder}, widths) = printline!(o, "-".^widths, widths, "+")

printrow(o::SimpleTable{<:StringBuilder}, columns, widths) = printline!(o, columns, widths, " ")
printrow(o::GridTable{<:StringBuilder}, columns, widths) = printline!(o, columns, widths, "|")

underline(o::SimpleTable{<:StringBuilder}, widths) = printline!(o, "-".^widths, widths, " ")
underline(o::GridTable{<:StringBuilder}, widths) = printline!(o, "=".^widths, widths, "+")

function print(::Type{T}, a::Array) where T <: MDtable
    nrow, ncol = size(a)
    rows = [[string(" ", a[r,c], " ") for c in 1:ncol] for r in 1:nrow]
    widths = [maximum(length, getindex.(rows, col)) for col in 1:ncol]
    o = T(StringBuilder())
    topbottom(o, widths)
    printrow(o, shift!(rows), widths)
    underline(o, widths)
    for row in rows
        printrow(o, row, widths)
    end
    topbottom(o, widths)
    return String(o.o)
end

end
