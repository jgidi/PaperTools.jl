using PaperTools
using PyPlot

using OrderedCollections

# We use OrderedDict's to plot in the same order the
# values are defined.
# The data must be a matrix with shape (Niterations, Nruns)


# Make up some data to plot
function fake_data(Niters, Nruns)
    decay_rate = 0.1rand()
    random_data = 0.4rand(Niters, Nruns)
    return exp.(random_data .- decay_rate*(1:Niters))
end


first_order = OrderedDict(
    "SPSA" => fake_data(50, 10),
    "CSPSA" => fake_data(50, 10),
)

second_order = OrderedDict(
    "SPSA" => fake_data(50, 10),
    "CSPSA" => fake_data(50, 10),
    ""      => nothing,                  # Empty place. For ordering purposes.
    "CSPSA scalar" => fake_data(50, 10),
)

quantum_natural = OrderedDict(
    "SPSA" => fake_data(50, 10),
    "CSPSA" => fake_data(50, 10),
    "SPSA scalar" => fake_data(50, 10),
    "CSPSA scalar" => fake_data(50, 10),
)


# You HAVE to pass the array of labels to show in the unified legend
# Make sure they correspond in order to the optimizers on each OrderedDict
#
# For example: Notice that the third element of 'second order' is empty,
# so that the next entry, "CSPSA scalar", is on the fourth place
# matching the ordering in "quantum_natural" and on the labels defined below.
labels = ["SPSA", "CSPSA", "SPSA scalar", "CSPSA scalar"]

# 'estimator' may be:
# :mean (showing dispersion as standard deviation)
# :median (showing dispersion as interquartile range)
# :both (show 2 rows: :mean on top and :median on bottom)
fig, ax = optimizersplot(first_order, second_order, quantum_natural,
                         estimator = :mean,
                         ylabel = "Cost",
                         labels = labels,
                         # xlims = (1, 50),
                         # ylims = (0.1^4, 1),
                         # xscale = :log10,
                         yscale = :log10,
                         )

# You can modify 'fig' and 'ax' as usual with PyPlot

# Save plot
fig.savefig("example_plot.pdf")
