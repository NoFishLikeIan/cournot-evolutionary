δc = 1
δb = 1
δa = 200

p(Q) = max(δa - δb * sum(Q), 0.) # Demand
c(q) = δc * q           # Costs

"""
Profit function
"""
function Π(Q) 
    price = p(Q) 
    return @. Q * price - c(Q)
end

# -- Equilibrium

q̄(N) = (δa - δc) / (δb * (N + 1))
p̄(N) = p(repeat([q̄(N)], N))

"""
Define the strategy set.
Guarantee that q̄ is in it.
"""
function Σ(N, spacesize)
    equilibrium = q̄(N)
    leftsize = spacesize ÷ 2
    step = equilibrium / leftsize
    
    return range(0, step * spacesize - step; step=step) |> collect
end
Σ(N) = Σ(N, N)