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

function plotquantities(evolutions, title; filename="q_heat")
    M, N, T = size(evolutions)

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

function plotgroupprices(groups, p, title; filename="p_group")
    N, T, I = size(groups)
    
    prices = zeros(Float64, I, T)

    plot(
        title=title, xaxis="t", yaxis="p(Q)", c="gray", alpha=0.5
    )

    for i in 1:I
        price = [p(sum(Q), N) for Q in eachcol(groups[:, :, i])]
        plot!(1:T, price, c="gray", alpha=0.5, label=false)
        prices[i, :] = price
    end

    plot!(1:T, mean(prices, dims=1)', c="red", label="mean(p(Q))", dpi=200)

    savefig("plots/$filename.png")
end