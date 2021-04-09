function adjacent(m, M)
    l = m == 1 ? M : m - 1
    r = m == M ? 1 : m + 1

    return l, r
end

function getrowfromidx(i, N)
    remainder = i % N

    if remainder == 0
        column = N
        row = (i ÷ N)
    else 
        column = remainder
        row = (i ÷ N) + 1
    end

    return row, column
end