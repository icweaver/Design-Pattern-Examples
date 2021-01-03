### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 4d273ccc-4da0-11eb-1c46-65f11f57c85f
using PlutoUI, Distributions

# ╔═╡ e4dc62ae-4da2-11eb-3079-e96176e66956
md"""
Say we have the following simulation data:
"""

# ╔═╡ a7281f72-4da0-11eb-3c5b-a5b7bc84d73c
mutable struct Simulation{N}
	heatmap::Array{Float64, N}
	stats::NamedTuple{(:mean, :std)}
end

# ╔═╡ c4680f0c-4da0-11eb-3ed5-7383f0d30af2
function simulate(distribution, dims, n)
	tp = ntuple(i -> n, dims)
	heatmap = rand(distribution, tp...)
	return Simulation{dims}(heatmap, (mean=mean(heatmap), std=std(heatmap)))
end

# ╔═╡ 1879abfa-4da1-11eb-1aad-778fac069d6f
sim = simulate(Normal(), 2, 1000)

# ╔═╡ f69d4828-4da2-11eb-3709-17b27c9a50af
md"""
We can access the `heatmap` and `stats` fields through the dot notation, and even update their values. We might not want the user to be able to do this though. What if they change the heatmap, but don't update the stats field accordingly? Or if we as the developer happen to change the name of the fields down the line? Having some control over what fields should be publicly accesible can help us with this. For example, formally defining the getters and setters below makes it explicit which part of the API the user should have access to.
"""

# ╔═╡ 00ef9bea-4da2-11eb-0b4c-571283396d3f
md"""
## Getters
"""

# ╔═╡ b6649276-4da1-11eb-10e7-2bc56471dee1
heatmap(s::Simulation) = s.heatmap

# ╔═╡ c83ed204-4da1-11eb-1a13-5db7496d7d83
stats(s::Simulation) = s.stats

# ╔═╡ d6e00832-4da1-11eb-25a1-ad4dacdcfdf1
md"""
## Setters
"""

# ╔═╡ 58059138-4da3-11eb-2992-038825ad8311
md"""
The nice part about having setters is that we can do invaldiation checks or to make sure the state of each field is consistent after any changes are made:
"""

# ╔═╡ 0b6aba16-4da2-11eb-2077-e741f35968f5
function heatmap!(
		s::Simulation{N},
		new_heatmap::AbstractArray{Float64, N},
) where {N}
	if length(unique(size(new_haetmap))) != 1
		error("All dimensions must have the same size")
	end
	s.heatmap = new_heatmap
	# Re-compute stats for consistency
	s.stats = (mean=mean(new_heatmap), std=std(new_heatmap))
	return nothing
end

# ╔═╡ b899fa34-4da3-11eb-2ebc-118169bfaa12
md"""
## Discouraging direct field access
"""

# ╔═╡ c6b59f0e-4da3-11eb-022e-23561f648b07
md"""
If all else fails, we can use the tried and true method of prepending an underscore to things that we don't want the user to be using. It doesn't actually do anything, but the power lies in the social contract. In the next [notebook](http://localhost:1234/edit?id=3b36ca80-4da4-11eb-2f41-259a0d4b39ab), we'll take a look at actually enforcing this contract progromatically.
"""

# ╔═╡ 6088f05a-4da0-11eb-1e77-035f75b9f665
TableOfContents()

# ╔═╡ Cell order:
# ╟─e4dc62ae-4da2-11eb-3079-e96176e66956
# ╠═a7281f72-4da0-11eb-3c5b-a5b7bc84d73c
# ╠═c4680f0c-4da0-11eb-3ed5-7383f0d30af2
# ╠═1879abfa-4da1-11eb-1aad-778fac069d6f
# ╟─f69d4828-4da2-11eb-3709-17b27c9a50af
# ╟─00ef9bea-4da2-11eb-0b4c-571283396d3f
# ╠═b6649276-4da1-11eb-10e7-2bc56471dee1
# ╠═c83ed204-4da1-11eb-1a13-5db7496d7d83
# ╟─d6e00832-4da1-11eb-25a1-ad4dacdcfdf1
# ╟─58059138-4da3-11eb-2992-038825ad8311
# ╠═0b6aba16-4da2-11eb-2077-e741f35968f5
# ╟─b899fa34-4da3-11eb-2ebc-118169bfaa12
# ╟─c6b59f0e-4da3-11eb-022e-23561f648b07
# ╠═6088f05a-4da0-11eb-1e77-035f75b9f665
# ╠═4d273ccc-4da0-11eb-1c46-65f11f57c85f
