δc = 1
δb = 1
δa = 20

p(Q) = δa - δb * sum(Q) # Demand
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

"""
Define the strategy set.
Guarantee that q̄ is in it.
"""
function Σ(N; spacesize=10)
    equilibrium = q̄(N)
    step = 2 * equilibrium / spacesize
    
    return range(0, step * spacesize; step=step) |> collect
end