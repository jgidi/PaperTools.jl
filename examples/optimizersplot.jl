using PaperTools

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
    "CSPSA2 otrawea" => rand(50, 10),
)


# 'estimator' may be:
# :mean (showing dispersion as standard deviation)
# :median (showing dispersion as interquartile range)
p = optimizersplot(sp1, sp2, sp2,
                   estimator = :mean,
                   ylabel = "Cost",
                   )
