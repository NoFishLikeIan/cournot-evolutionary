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

function plotgroupquantities(
    group, title; 
    filename="q_group_heat")
    
    N, T = size(group)
    equil = q̄(N)
    u = maximum(Σ(N))

    gradient = cgrad(:balance, [0., equil / u, 1.])

    heatmap(
        group,
        c=gradient, clims=(0., u),
        xaxis="t",
        dpi=200, title=title)

    savefig("plots/$filename.png")
end

function plotprices(evolutions, title; filename="p_group")
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

    hline!([p̄(N)], c=:black, linestyle=:dash, label="$(p̄(N)) Equil.")

    savefig("plots/$filename.png")
end


function plotquantities(evolutions, title; filename="q_group")
    M, N, T = size(evolutions)
    quantities = zeros(Float64, M, T)

    plot(xaxis="t", yaxis="q", dpi=200, title=title)

    for m in 1:M
        groupquantity = mean(evolutions[m, :, :], dims=1)
        plot!(1:T, vec(groupquantity), c="gray", alpha=0.5, label=false)
        quantities[m, :] = groupquantity
    end

    meanquantity = vec(mean(quantities, dims=1))

    plot!(1:T, meanquantity, c="red", label="p̄(Q)")

    hline!([q̄(N)], c=:black, linestyle=:dash, label="$(q̄(N)) Equil.")

    savefig("plots/$filename.png")

end