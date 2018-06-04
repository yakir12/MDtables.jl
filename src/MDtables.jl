__precompile__()
module MDtables

using StringBuilders, FixedSizeStrings
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

struct Cell{H, W}
    ss::NTuple{H, FixedSizeString{W}}
end
Cell(a::Vector{<:AbstractString}) = Cell((FixedSizeString.(a)...))
function Cell(x::String) 
    a = split(x, '\n')
    h = maximum(length, a)
    a .= rpad.(a, h)
    Cell(a)
end
Cell(x) = Cell(string(x))
geth(x::Cell{H,W}) where {H, W} = H
getw(x::Cell{H,W}) where {H, W} = W
pad(x::Cell{H, W}, h, w) where {H, W} = Cell([rpad.(x.ss, w)..., (" "^w for i in H+1:h)...])

function printline(o, cells, l, delimiter)
    for cell in cells
        append!(o, delimiter)
        append!(o, cell.ss[l])
    end
    append!(o, delimiter)
    append!(o, "\n")
end
printline(o::SimpleTable, cells, l) = printline(o.o, cells, l, " ")
printline(o::MultilineTable, cells, l) = printline(o.o, cells, l, " ")
printline(o::GridTable, cells, l) = printline(o.o, cells, l, "|")
printseparator(o, ws, c, d) = printline(o.o, [Cell((FixedSizeString(c^w), )) for w in ws], 1, d)
printtopbottom(o::SimpleTable, ws) = nothing
printtopbottom(o::MultilineTable, ws) = printseparator(o, ws, "-", "-")
printtopbottom(o::GridTable, ws) = printseparator(o, ws, "-", "+")
printdelimiter(o::SimpleTable, ws) = nothing
printdelimiter(o::MultilineTable, ws) = printseparator(o, ws, " ", " ")
printdelimiter(o::GridTable, ws) = printtopbottom(o, ws)
printunderline(o::SimpleTable, ws) = printseparator(o, ws, "-", " ")
printunderline(o::MultilineTable, ws) = printseparator(o, ws, "-", " ")
printunderline(o::GridTable, ws) = printseparator(o, ws, "=", "+")
function printrow(o, cells)
    for l in 1:geth(cells[1])
        printline(o, cells, l)
    end
end
function getcells(a)
    b = Cell.(a)
    nrow, ncol = size(b)
    hs = [maximum(geth, b[r, :]) for r in 1:nrow]
    ws = [maximum(getw, b[:, c]) for c in 1:ncol]
    for r in 1:nrow, c in 1:ncol
        b[r, c] = pad(b[r, c], hs[r], ws[c])
    end
    return (b, ws, nrow)
end

function print(::Type{T}, a::A) where {T <: MDtable, A <: AbstractArray}
    b, ws, nrow = getcells(a)
    if T <: SimpleTable
        @assert all(geth(bi) == 1 for bi in b) "can't print multiline table as a simple_table"
    end
    o = T(StringBuilder())
    printtopbottom(o, ws)
    printrow(o, b[1, :])
    printunderline(o, ws)
    for r in 2:nrow-1
        printrow(o, b[r, :])
        printdelimiter(o, ws)
    end
    printrow(o, b[nrow, :])
    printtopbottom(o, ws)
    return String(o.o)
end

end
