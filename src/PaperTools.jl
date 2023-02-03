module PaperTools

using Plots
using Colors: distinguishable_colors
using Statistics

function __init__()
    pyplot()                    # Load PyPlot backend for Plots
end


include("include/optimizersplot.jl")

end # module PaperTools
