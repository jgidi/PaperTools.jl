
export optimizersplot

get_quantile(A::AbstractArray, p; dims) = mapslices(x->quantile(x, p), A, dims=dims)

function get_statistics(data, estimator=:median, symmetric_std=false)


    if estimator == :median
        fcentral = median(data, dims = 2) |> vec
        area = (
            get_quantile(data, 0.25, dims=2) |> vec,
            get_quantile(data, 0.75, dims=2) |> vec,
        )
    elseif estimator == :mean
        fcentral = mean(data, dims = 2)  |> vec
        dispersion = std(data, dims = 2) |> vec

        lower = fcentral - dispersion
        upper = fcentral + dispersion
        if !symmetric_std
            lower = fcentral # fcentral - dispersion may be negative
        end
        area = (lower, upper)
    else
        throw("Please, provide 'estimator = :median' or 'estimator = :mean'")
    end

    return fcentral, area
end

function optimizersplot(data_dicts...;
                        estimator = :both,
                        xlabel = "Iterations",
                        ylabel = "Cost",
                        titles = ["First order", "Second order", "Quantum Natural"],
                        symmetric_std = false,
                        figsize = :default, # Tuple of reals,
                        xlims = :default,
                        ylims = :default,
                        yscale = :default,
                        xscale = :default,
                        gridalpha = 0.3,
                        fillalpha = 0.3,
                        )



    plt = PyPlot.plt
    data_dicts = collect(data_dicts)

    # Make array of estimators
    estimators = estimator == :both ? [:mean, :median] : [estimator]

    Ncols = length(data_dicts)
    Nrows = length(estimators)

    # Turn data_dicts into a Matrix
    data_dicts = repeat(reshape(data_dicts, 1, :), Nrows)

    # plt.rcParams["font.family"] = "serif"
    # plt.rcParams["mathtext.font"] = "serif"

    # Create subplot layout
    fig, ax = plt.subplots(nrows=Nrows, ncols=Ncols)
    ax = reshape(ax, Nrows, Ncols)

    # Set figure size
    if figsize == :default
        figsize = Nrows == 1 ? (800, 270) : (800, 450)
    end
    fig.set_figwidth(figsize[1]/100)
    fig.set_figheight(figsize[2]/100)

    # Gather all unique labels
    labels = vcat(collect.(keys.(data_dicts))...)
    labels = sort(unique(labels), by=length)

    # Prepare colors
    seed = [RGB(1, 1, 1)] # Avoid colors close to white
    all_colors = distinguishable_colors(length(labels), seed, dropseed=true)
    all_colors = map(c->(red(c), green(c), blue(c)), all_colors)

    lines = Dict()
    colors = Dict(zip(labels, all_colors))
    for row in 1:Nrows
        for col in 1:Ncols
            for (key, data) in data_dicts[row, col]

                center, area = get_statistics(data,
                                              estimators[row],
                                              symmetric_std)

                iters = 0:(length(center)-1)

                lines[key] = (
                    # Solid line
                    ax[row, col].plot(iters, center,
                                      color = colors[key],
                                      label = key)[],
                    # Shade
                    ax[row, col].fill_between(iters,
                                              area[1], area[2],
                                              color = colors[key],
                                              alpha = fillalpha)
                )
            end
        end
    end

    # ===== From here it is just Formatting & Style

    # Shared axes
    # x
    for i in 1:Nrows
        for axx in ax[i, 2:end]
            axx.sharey(ax[i, 1])
        end
    end
    # y
    for i in 1:Ncols
        for axx in ax[2:end, i]
            axx.sharex(ax[1, i])
        end
    end

    # Hide corresponding ticks
    function hideticks(ax, ticks=:x)
        ticklabels = Meta.parse("get_$(ticks)ticklabels")
        setp(ax[ticklabels](), visible=false)
    end

    hideticks.(ax[1:end-1, :], :x) # x-ticks
    hideticks.(ax[:,   2:end], :y) # y-ticks

    # Set titles
    [ax[1, i].title.set_text(titles[i]) for i in 1:3]

    # Set xlabels to bottom row
    [ax.set_xlabel(xlabel) for ax in ax[end, :]]

    # Set xlims
    if xlims == :default
        maxlength = size.(values(data_dicts[1, 1]), 1) |> maximum
        xlims = (0, maxlength-1)
    end
    [ax.set_xlim(xlims...) for ax in ax[end, :]]

    # Set ylims
    if ylims != :default
        [ax.set_ylim(ylims...) for ax in ax[:, 1]]
    end

    # Set ylabels to left column
    for (row, est) in enumerate(estimators)
        ax[row, 1].set_ylabel(ylabel*" ($(string(est)))")
    end

    # Log scales
    xscale == :log10 && [ax[end, co].set_xscale("log") for co in 1:Ncols]
    yscale == :log10 && [ax[row, 1].set_yscale("log") for row in 1:Nrows]

    # Modifications to all subplots
    for ax in ax
        # Set grid
        ax.grid(alpha = gridalpha)

        # Ticks pointing inside
        ax.xaxis.set_tick_params(direction="in", which="both")
        ax.yaxis.set_tick_params(direction="in", which="both")
    end

    # Unique legend for all subplots
    markers = [lines[l] for l in labels]
    fig.legend(markers,
               labels,
               ncol = length(labels),
               loc = "lower center",
               # loc="upper center",
               frameon = false,
               )

    shift = 0.07
    fig.tight_layout(rect=(0, shift, 1, 1)) # left, bottom, right, top
    # fig.tight_layout(rect=(0, 0, 1, 1-shift)) # left, bottom, right, top

    return fig, ax
end
