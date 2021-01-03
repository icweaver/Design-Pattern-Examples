# Calculator.jl
module Calculator

# Include sub-modules
include("Mortgage.jl")
using .Mortgage: payment

# Functions for the main module
include("funcs.jl")

end # module
