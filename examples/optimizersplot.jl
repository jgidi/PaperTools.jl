using PaperTools
using Plots

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


sp1 = OrderedDict(
    "SPSA" => fake_data(50, 10),
    "CSPSA" => fake_data(50, 10),
)

sp2 = OrderedDict(
    "SPSA2" => fake_data(50, 10),
    "CSPSA2" => fake_data(50, 10),
    "CSPSA2 full" => fake_data(50, 10),
    "CSPSA2 scalar" => fake_data(50, 10),
    "CSPSA2 otro" => fake_data(50, 10),
)

sp3 = OrderedDict(
    "SPSA QN" => fake_data(50, 10),
    "CSPSA QN" => fake_data(50, 10),
    "CSPSA otro QN " => fake_data(50, 10),
    "CSPSA QN scalar" => fake_data(50, 10),
    "SPSA QN scalar" => fake_data(50, 10),
)

# 'estimator' may be:
# :mean (showing dispersion as standard deviation)
# :median (showing dispersion as interquartile range)
p = optimizersplot(sp1, sp2, sp3,
                   estimator = :mean,
                   ylabel = "Cost",
                   )

savefig(p, "example_plot.pdf")
