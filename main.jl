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


function evolve(M, N; T=100, ρ=0.)    
    evolution = zeros(M, N, T)

    evolution[:, :, 1] = sample(Σ(N), (M, N))

    for t in 2:T
        current = @view evolution[:, :, t - 1]
        pay = computepayoffs(current)
        next = evolvegroups(current, pay; ρ=ρ)
        evolution[:, :, t] = next
    end

    return evolution

end


M, N = 10, 20
T = 200

params = [(0., "low"), (0.5, "medium"), (1., "high")]

print("Theoretical cournot equilibria: q̄ = $(q̄(N)) p̄ = $(p̄(N))\n")

for (ρ, path) in params
    
    print("Simulating with ρ=$ρ≭")
    evolutions = evolve(M, N; T=T, ρ=ρ)
    
    # Local
    group = reshape(evolutions[1, :, :], (N, T))
    plotgroupquantities(
        group, "Q, N = $N";
        filename="$path/local_quantity.png")

    # Global
    plotprices(evolutions, "Average price per group";filename="$path/meanprice.png")

    plotquantities(evolutions, "Average quantity per group"; filename="$path/meanquantity.png")
end