using Base.Threads, Random
using StatsBase
using Statistics
using IterTools

using Plots, Printf

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
        Ngroups = length(gs)

        profit = vec(pay[gs, :])

        πmin, πmax = extrema(profit)
        soft = @. (profit - πmin) / (πmax - πmin)
        prob = soft ./ sum(soft)

        birth = sample(1:(N * Ngroups), pweights(prob))

        row, col = getrowfromidx(birth, N)

        next[m, death] = next[gs[row], col]
    end

    return next
end


function evolve(M, N; T=100, ρ=0., seed=0.2)    
    evolution = zeros(M, N, T)

    # Populate the original generation
    equilN = floor(Int64, N * seed)
    randomN = N - equilN

    Σ₀ = repeat([q̄(N)], equilN)

    @threads for m in 1:M
        evolution[m, :, 1] = vcat(Σ₀, sample(Σ(N), randomN))
    end

    # Evolution
    for t in 2:T
        current = @view evolution[:, :, t - 1]
        pay = computepayoffs(current)
        next = evolvegroups(current, pay; ρ=ρ)
        evolution[:, :, t] = next
    end

    return evolution

end


M, N = 100, 10
T = 200

params = [
    (0., "low"),
    (0.5, "medium"),
    (1., "high")
]


optq =  @sprintf("%.2f", q̄(N))
optp = @sprintf("%.2f", p̄(N))

print("Theoretical cournot equilibria: q̄ = $optq p̄ = $optp\n")

for (ρ, path) in params

    print("Simulating with ρ=$ρ\n")
    evolutions = evolve(M, N; T=T, ρ=ρ, seed=0.9)
    
    # Local
    group = reshape(evolutions[1, :, :], (N, T))
    plotgroupquantities(
        group, "q̄ = $optq, N = $N";
        filename="$path/local_quantity.png")

    # Global
    plotprices(evolutions, "Average price per group; ρ = $(ρ)";filename="$path/meanprice.png")

    plotquantities(evolutions, "Average quantity per group; ρ=$(ρ)"; filename="$path/meanquantity.png")
end