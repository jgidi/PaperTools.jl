export optimizersplot

get_quantile(A::AbstractArray, p; dims) = mapslices(x->quantile(x, p), A, dims=dims)
squeeze(A) = reshape(A, Tuple(i for i in size(A) if i != 1))

function get_statistics(data, estimator=:median)


    if estimator == :median
        fcentral = median(data, dims = 2) |> squeeze
        area = (
            get_quantile(data, 0.25, dims=2) |> squeeze,
            get_quantile(data, 0.75, dims=2) |> squeeze,
        )
    elseif estimator == :mean
        fcentral = mean(data, dims = 2)  |> squeeze
        dispersion = std(data, dims = 2) |> squeeze
        area = (fcentral - dispersion, fcentral + dispersion)
    else
        throw("Please, provide 'estimator = :median' or 'estimator = :mean'")
    end

    return fcentral, area
end

function build_subplot(data_dict, estimator, masknegatives)
    p = plot()
    N = length(data_dict)

    seed = [RGB(1, 1, 1)] # Avoid colors close to white
    colors = distinguishable_colors(N, seed, dropseed=true)
    i = 0
    for (key, val) in data_dict
        fc, area = get_statistics(val, estimator)

        # Mask negative ribbon values
        if masknegatives
            @. area[1][@. area[1] < eps() ] = eps()
        end

        # plot!(p, 0:(length(fc)-1), fc,
        plot!(p, fc,
              xlims=(1, length(fc)),
              linewidth=2,
              fillrange=area,
              fillalpha=0.4,
              label=key,
              color=colors[i+=1],
              )
    end

    return p
end

function optimizersplot(data_dicts...;
                        estimator = :both,
                        xlabel = "Iterations",
                        ylabel = "Cost",
                        title = ["First order" "Second order" "Quantum Natural"],
                        masknegatives = false,
                        kwargs...)


    if estimator == :both
        subp_mean   = build_subplot.(data_dicts, :mean, masknegatives)   |> collect
        subp_median = build_subplot.(data_dicts, :median, masknegatives) |> collect

        # Make Nx2 matrix of plots
        subplots = hcat(subp_mean, subp_median)

        # Other params
        figsize  = (1200, 600)

        # Anotate estimators
        plot!(subplots[1, 1], ylabel = ylabel*" (mean)")
        plot!(subplots[1, 2], ylabel = ylabel*" (median)")
    else
        # Make Nx1 matrix of plots
        subplots = build_subplot.(data_dicts, estimator, masknegatives) |> collect
        subplots = reshape(subplots, :, 1)

        # Other params
        figsize  = (1200, 400)

        # Annotate estimator
        plot!(subplots[1, 1], ylabel = ylabel*" ($(string(estimator)))")
    end

    # Y Labels and ticks on leftmost subplots only
    plot!.(subplots[2:end, :], yformatter=_->"")

    # X labels and ticks on the last row only
    plot!.(subplots, xformatter=_->"")
    plot!.(subplots[:, end], xformatter=:auto, xlabel=xlabel)

    # Titles
    for (i, sp) in enumerate(subplots[:, 1])
        plot!(sp, title=title[i])
    end

    return plot(subplots...;
                layout = reverse(size(subplots)),
                thickness_scaling = 1.3,
                size = figsize,
                tickfontsize = 12,
                guidefontsize = 12,
                grid = true,
                framestyle = :box,
                link = :y,
                kwargs...)
end
