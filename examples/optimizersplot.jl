using PaperTools
using Plots

using OrderedCollections

# We use OrderedDict's to plot in the same order the
# values are defined.
# The data must be a matrix with shape (Niterations, Nruns)

sp1 = OrderedDict(
    "SPSA" => rand(50, 10),
    "CSPSA" => rand(50, 10),
)

sp2 = OrderedDict(
    "SPSA2" => rand(50, 10),
    "CSPSA2" => rand(50, 10),
    "CSPSA2 full" => rand(50, 10),
    "CSPSA2 scalar" => rand(50, 10),
    "CSPSA2 otro" => rand(50, 10),
)

sp3 = OrderedDict(
    "SPSA QN" => rand(50, 10),
    "CSPSA QN" => rand(50, 10),
    "CSPSA otro QN " => rand(50, 10),
    "CSPSA QN scalar" => rand(50, 10),
    "SPSA QN scalar" => rand(50, 10),
)

# 'estimator' may be:
# :mean (showing dispersion as standard deviation)
# :median (showing dispersion as interquartile range)
p = optimizersplot(sp1, sp2, sp3,
                   estimator = :mean,
                   ylabel = "Cost",
                   )

savefig(p, "example_plot.pdf")
