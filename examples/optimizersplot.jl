using PaperTools
using PyPlot

# Make up some data to plot
function fake_data(Niters, Nruns, decay_rate=:random)
    decay_rate == :random && (decay_rate = 0.1rand())
    random_data = 0.4rand(Niters, Nruns)
    return exp.(random_data .- decay_rate*(1:Niters))
end

# Each dictionary defines a subplot, with as many lines as entries on the Dict.
# The plot will have a single legend for all subplots, where the curves will be
# grouped in a single color and name depending on their key in the dictionary.
# That is, all curves with the key "SPSA" will be plotted with the same color,
# and the same holds for other labels.

# The data must be a matrix with shape (Niterations, Nruns)

first_order = Dict(
    "SPSA"  => fake_data(50, 10),
    "CSPSA" => fake_data(50, 10),
)

second_order = Dict(
    "SPSA"  => fake_data(50, 10),
    "CSPSA" => fake_data(50, 105),
    "CSPSA scalar" => fake_data(50, 10),
)

quantum_natural = Dict(
    "SPSA" => fake_data(50, 10),
    "CSPSA full" => fake_data(50, 10),
    "SPSA scalar" => fake_data(50, 10),
    "CSPSA scalar" => fake_data(50, 10),
)


# 'estimator' may be:
# :mean (showing dispersion as standard deviation)
# :median (showing dispersion as interquartile range)
# :both (show 2 rows: :mean on top and :median on bottom)
fig, ax = optimizersplot(first_order, second_order, quantum_natural,
                         estimator = :both,
                         ylabel = "Cost",
                         # xlims = (1, 50),
                         # ylims = (0.1^4, 1),
                         # xscale = :log10,
                         yscale = :log10,
                         # symmetric_std = true,
                         )

# You can modify 'fig' and 'ax' as usual with PyPlot

# Save plot
fig.savefig("example_plot.pdf")
