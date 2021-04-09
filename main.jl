using Base.Threads, Random
using StatsBase
using Statistics
using IterTools
using Plots

Random.seed!(11148705)

include("cournot.jl")
include("utils/coord.jl")
include("utils/plot.jl")

function computepayoffs(groups)
    M, N = size(groups)
    pay = zeros(Float64, M, N)

    @threads for m in 1:M
        Q = groups[m, :]
        pay[m, :] =  Π(Q)
    end

    return pay
end

"""
Each turn a player per node dies. It is replaced by the best performing player from its node or, with some probability, the adjacent nodes.
"""
function evolvegroups(groups, pay; ρ=0.)
    M, N = size(groups)
    next = copy(groups)

    for m in 1:M
        death = sample(1:N)
        
        l, r = adjacent(m, M)
        gs = rand() < ρ ? [l, m, r] : [m]

        profit = vec(pay[gs, :])

        πmin, πmax = extrema(profit)
        soft = @. (profit - πmin) / (πmax - πmin)
        prob = soft ./ sum(soft)

        birth = sample(1:(N * length(gs)), pweights(prob))

        row, col = getrowfromidx(birth, N)

        next[m, death] = next[gs[row], col]
    end

    return next
end


function evolve(M, N; T=100)    
    evolution = zeros(M, N, T)
    evolution[:, :, 1] = rand(Σ(N), (M, N))
    
    for t in 2:T
        current = @view evolution[:, :, t - 1]
        pay = computepayoffs(current)
        next = evolvegroups(current, pay)
        evolution[:, :, t] = next
    end

    return evolution

end


M, N = 10, 20
T = 100
evolutions = evolve(M, N; T=T)

print("Cournot equilibrium $(q̄(N))")

plotpayoffs(
    evolution, computepayoffs,
    "Π, M = $M, N = $N"
)

group = reshape(evolutions[1, :, :], (N, T))

plotgroupquantities(group, "Q, N = $N")