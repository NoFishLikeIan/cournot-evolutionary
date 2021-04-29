include("cournot.jl")

using LaTeXStrings

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
    payoffs = Π([q₁, q₂])
    return payoffs[1] / sum(payoffs)
end

heatmap(
    x, y, (q₁, q₂) -> probability(q₁, q₂), 
    xlabel="q₁", ylabel="q₂",
    colorbar_title="Repr. prob. of 1",
    dpi=200, c=:coolwarm
)


scatter!([cournot], [cournot], color=:black, label=false)

annotate!(cournot + 5, cournot, text(equil, :black, :left, 10))

savefig("plots/theory/twoplayers.png")
