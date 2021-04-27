δc = 10.
δb = 1.
δa = 500.


# Demand
p(Q) = max(δa - δb * sum(Q), 1.)
p(q, N) = δa - δb * (q * N)

"""
Profit function
"""
function π(q, p) q * (p - δc) end
function Π(Q) π.(Q, p(Q)) end

# -- Equilibrium
q̄(N) = (δa - δc) / (δb * (N + 1))
p̄(N) = p(q̄(N), N)

"""
Define the strategy set. Guarantee that q̄ is in it.
"""
function Σ(N, spacesize)
    equilibrium = q̄(N)
    leftsize = spacesize ÷ 2
    step = equilibrium / leftsize
    
    return range(0, step * spacesize - step; step=step) |> collect
end

Σ(N) = Σ(N, N)