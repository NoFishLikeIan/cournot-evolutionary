using LaTeXStrings, Plots

include("cournot.jl")


N = 5

other = repeat([q̄(N)], N - 1)

"""
Best response in terms of payoffs
"""
function bestpayoff(q)

    Q = [other..., q]
    payoffs = Π(Q)

    return payoffs[end]
end


"""
Best response in terms of probability
"""
function bestprobability(q)

    Q = [other..., q]
    payoffs = Π(Q)

    probabilities = payoffs ./ sum(payoffs)

    return probabilities[end]

end


quantities = range(0, 150, length=200)
plot(
    quantities, bestpayoff, 
    xlabel="q", label="Payoffs",
    color=:blue, legend=:topleft,
    dpi=200
)
vline!([q̄(N)], color=:black, linestyle=:dash, label=false)

equil = L"\leftarrow \overline{q} \approx %$(round(Int64, q̄(N)))"

annotate!(q̄(N), 2000, text(equil, :black, :left, 10))

plot!(
    twinx(), quantities, bestprobability,
    label="Reproduction Prob.", xticks=:none,
    color=:red, legend=:bottomright
)


savefig("plots/theory/theoretical_prob.pdf")


# Two players

N = 2
x = y = 0:250

cournot = q̄(N)

equil = L"\overline{q} \approx %$(round(Int64, q̄(N)))"

function probability(q₁, q₂)

    Π₁, Π₂ = Π([q₁, q₂])

    prob = Π₁ / (Π₁ + Π₂)

    return Π₁ ≥ 0 ? prob : 1 - prob
end

heatmap(
    x, y, probability, 
    xlabel="q₁", ylabel="q₂",
    colorbar_title="Repr. prob. of 1",
    dpi=200, c=:coolwarm, aspect_ratio=1,
    xlims=extrema(x), ylims=extrema(y)
)


scatter!([cournot], [cournot], color=:black, label=false)

annotate!(cournot + 5, cournot, text(equil, :black, :left, 10))

savefig("plots/theory/twoplayers.png")


totalpayoffs(q₁, q₂) = Π([q₁, q₂])[1] / sum(Π([cournot, cournot]))

heatmap(
    x, y, (q₁, q₂) -> totalpayoffs(q₁, q₂), 
    xlabel="q₁", ylabel="q₂",
    colorbar_title="Total payoffs rel. Cournot",
dpi=200, c=:coolwarm
)


scatter!([cournot], [cournot], color=:black, label=false)

annotate!(cournot + 5, cournot, text(equil, :black, :left, 10))

savefig("plots/theory/twoplayerspi.png")
