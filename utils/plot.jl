function plotpayoffs(evolutions, computepayoffs, title; filename="payoff_heat")
    M, N, T = size(evolutions)
    pay = zeros(Float64, M, T)

    for t in 1:T
        pay[:, t] = mean(computepayoffs(evolutions[:, :, t]), dims=2)
    end

    groups = ["G$m" for m in 1:M]

    limit = maximum(abs.(pay))

    heatmap(
        1:T, groups, pay, 
        clim=(-limit, limit),
        title=title, xaxis="time", dpi=200)

    savefig("plots/$filename.png")
    
end

function plotgroupquantities(group, title; path=["p_group.png"])
    
    N, T = size(group)

    equil = q̄(N)
    
    gradient = cgrad(:coolwarm, [0, equil, 60])

    heatmap(
        1:T, 1:N, group,
        c=gradient,
        yticks=1:N, xlabel="T",
        title="Strategy played, q̄ = $(@sprintf("%.2f", equil))"
    )

    dir = copy(path)
    filename = pop!(dir)

    dir = joinpath(dir...)

    if !isdir(dir) mkpath(dir) end

    savefig(joinpath(dir, filename))
end

function plotprices(evolutions, title; path=["p_group.png"])
    M, N, T = size(evolutions)
    prices = zeros(Float64, M, T)

    plot(xaxis="t", yaxis="p(Q)", dpi=200, title=title)

    for m in 1:M
        pricegroup = map(p, eachcol(evolutions[m, :, :]))
        plot!(1:T, pricegroup, c="gray", alpha=0.5, label=false)
        prices[m, :] = pricegroup
    end

    meanp = vec(mean(prices, dims=1))

    plot!(1:T, meanp, c="red", label="q̄")


    eqlabel = "$(@sprintf("%.2f", p̄(N))) Equil."
    hline!([p̄(N)], c=:black, linestyle=:dash, label=eqlabel)

    dir = copy(path)
    filename = pop!(dir)

    dir = joinpath(dir...)

    if !isdir(dir) mkpath(dir) end

    savefig(joinpath(dir, filename))
end

    
function plotquantities(evolutions, title; path=["p_group.png"])
    M, N, T = size(evolutions)
    quantities = zeros(Float64, M, T)

    plot(xaxis="t", yaxis="q", dpi=200, title=title)

    for m in 1:M
        groupquantity = mean(evolutions[m, :, :], dims=1)
        plot!(1:T, vec(groupquantity), c="gray", alpha=0.1, label=false)
        quantities[m, :] = groupquantity
    end

    meanquantity = vec(mean(quantities, dims=1))

    plot!(1:T, meanquantity, c="red", label="p̄(Q)")


    eqlabel = "$(@sprintf("%.2f", q̄(N))) Equil."
    hline!([q̄(N)], c=:black, linestyle=:dash, label=eqlabel)

    dir = copy(path)
    filename = pop!(dir)

    dir = joinpath(dir...)

    if !isdir(dir) mkpath(dir) end

    savefig(joinpath(dir, filename))

end