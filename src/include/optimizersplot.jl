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
                        estimator = :median,
                        ylabel = "Cost",
                        title = ["First order" "Second order" "Quantum Natural"],
                        masknegatives = false,
                        kwargs...)

    subplots = build_subplot.(data_dicts, estimator, masknegatives)

    plot!(subplots[1], ylabel=ylabel)
    for sp in subplots[2:end]
        plot!(sp,
              yformatter=_->"",
              # left_margin  = -4Plots.mm,
              )
    end

    return plot(subplots...;
                layout = (1, length(subplots)), # Make horizontal
                xlabel = "Iterations",
                # fontfamily = "serif-roman",
                title = title,
                thickness_scaling=1.3,
                # bottom_margin=2Plots.mm,
                size = (1200, 400),
                grid = true,
                framestyle = :box,
                link = :y,
                kwargs...)
end
