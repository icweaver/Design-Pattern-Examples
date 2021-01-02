### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 47628bcb-21c1-4f80-b068-9148397304f4
using PlutoUI, BenchmarkTools

# ╔═╡ 5c5c0a22-4c94-11eb-0730-d52cda1448a3
random_data(n) = isodd(n) ? rand(Int, n) : rand(Float64, n)

# ╔═╡ 1a758cb3-7bdb-4e13-b2eb-86afac921ce6
md"""
We can take a look at the **Intermediate Representation (IR)** to see if we have a type instability:
"""

# ╔═╡ 0e180c47-a044-4500-bfea-05724d3b8ffc
with_terminal() do
	@code_warntype random_data(3)
end

# ╔═╡ 52cbb597-0786-42e4-92bf-2f47c21149fb
md"""
The union means that the compiler needs to generate extra code to support both the Int type and Float type, instead of optimized code for a single type.
"""

# ╔═╡ 3cdd4c77-a119-4a54-adfe-21b298784c86
function double_sum_of_random_data(n)
	data = random_data(n)
	total = 0
	for v in data
		total += 2 * v
	end
	return total
end

# ╔═╡ bdff60c0-edb3-4b64-9b82-4a2642f6851a
with_terminal() do
	@btime double_sum_of_random_data(100_000)
	@btime double_sum_of_random_data(100_001)
end

# ╔═╡ ec60a3f6-5ce9-47b2-b3fc-f64e0e72666c
md"""
The function is faster when `n` is odd, most likely because the RNG is better for Ints than Floats.
"""

# ╔═╡ 285b571a-d845-4cc8-888e-228bb39cdf81
with_terminal() do
	@code_warntype double_sum_of_random_data(100_000)
end

# ╔═╡ 3caec2f7-31ed-4801-8e51-25accf463d5a
md"""
That's a lot of unions. Let's see what we can do with barrier functions:
"""

# ╔═╡ 2bc438e8-7426-47c9-9306-8c8fa644aec5
function double_sum(data)
	total = 0
	for v in data
		total += 2 * v
	end
end

# ╔═╡ 1a5062ff-a274-492d-8973-78b71235597d
function double_sum_of_random_data_barrier(n)
	data = random_data(n)
	return double_sum(data)
end

# ╔═╡ 5a637a01-ce9d-4ae4-af99-8765384d8f69
with_terminal() do
	@code_warntype double_sum_of_random_data_barrier(100_000)
end

# ╔═╡ 298007a7-1b86-4118-8830-6a19633f456c
md"""
That's way better! Let's check out the difference in performance:
"""

# ╔═╡ 42ccb9df-2df5-4261-a719-f5e8c2517214
with_terminal() do
	println("No barrier")
	@btime double_sum_of_random_data(100_000)
	@btime double_sum_of_random_data(100_001)
	println("Barrier")
	@btime double_sum_of_random_data_barrier(100_000)
	@btime double_sum_of_random_data_barrier(100_001)
end

# ╔═╡ 2040fbb6-9166-4e73-b425-fea2600502c5
md"""
This is definitely faster, but it still differs substantially if we use Ints vs. Floats. This is because we still have a type instability hiding in our nested function. Let's take a look at it:
"""

# ╔═╡ 3d6ecc77-e77e-4096-b23d-79641c5636a6
with_terminal() do
	@code_warntype double_sum(rand(Float64, 3))
end

# ╔═╡ 4c5c01a4-2a04-47fb-82d5-f96bbb5546bd
md"""
Yep, it's right there in the accumulator. We hard coded `total = 0`, which is an Int, which then needs to get converted to a Float in `total += 2 * v` whenver that kind of data is passed to it. We can generalize this by using `zero` instead:
"""

# ╔═╡ 083be290-4206-419c-9ded-54f13ab10753
function double_sum_general(data)
	total = zero(eltype(data))
	for v in data
		total += 2 * v
	end
end

# ╔═╡ 0fe59ecd-38c7-4ef7-b6a5-c8a0c32c355a
with_terminal() do
	@code_warntype double_sum_general(rand(Float64, 3))
end

# ╔═╡ d22b36ce-485e-4535-a9c5-a924a069bde2
md"""
Alright, the union is gone! We could have also done this parametrically, with similar results:
"""

# ╔═╡ 4089c40d-62f0-4426-8ff4-8e4c2e471af2
function double_sum_general_parametric(data::AbstractVector{T}) where {T <: Number}
	total = zero(T)
	for v in data
		total += 2 * v
	end
end

# ╔═╡ 5caac934-d15c-40dc-b6cb-54cd7c8766c0
with_terminal() do
	@btime double_sum_general(rand(Int, 100_000))
	@btime double_sum_general(rand(Int, 100_001))
	@btime double_sum_general_parametric(rand(Int, 100_000))
	@btime double_sum_general_parametric(rand(Int, 100_001))
end

# ╔═╡ d5dc1615-3e77-4d1e-8d94-352c51e985ce
md"""
The function is now roughly the same speed for both Ints and Floats, and just as fast!
"""

# ╔═╡ Cell order:
# ╠═5c5c0a22-4c94-11eb-0730-d52cda1448a3
# ╟─1a758cb3-7bdb-4e13-b2eb-86afac921ce6
# ╠═0e180c47-a044-4500-bfea-05724d3b8ffc
# ╟─52cbb597-0786-42e4-92bf-2f47c21149fb
# ╠═3cdd4c77-a119-4a54-adfe-21b298784c86
# ╠═bdff60c0-edb3-4b64-9b82-4a2642f6851a
# ╟─ec60a3f6-5ce9-47b2-b3fc-f64e0e72666c
# ╠═285b571a-d845-4cc8-888e-228bb39cdf81
# ╟─3caec2f7-31ed-4801-8e51-25accf463d5a
# ╠═2bc438e8-7426-47c9-9306-8c8fa644aec5
# ╠═1a5062ff-a274-492d-8973-78b71235597d
# ╠═5a637a01-ce9d-4ae4-af99-8765384d8f69
# ╟─298007a7-1b86-4118-8830-6a19633f456c
# ╠═42ccb9df-2df5-4261-a719-f5e8c2517214
# ╟─2040fbb6-9166-4e73-b425-fea2600502c5
# ╠═3d6ecc77-e77e-4096-b23d-79641c5636a6
# ╟─4c5c01a4-2a04-47fb-82d5-f96bbb5546bd
# ╠═083be290-4206-419c-9ded-54f13ab10753
# ╠═0fe59ecd-38c7-4ef7-b6a5-c8a0c32c355a
# ╟─d22b36ce-485e-4535-a9c5-a924a069bde2
# ╠═4089c40d-62f0-4426-8ff4-8e4c2e471af2
# ╠═5caac934-d15c-40dc-b6cb-54cd7c8766c0
# ╟─d5dc1615-3e77-4d1e-8d94-352c51e985ce
# ╠═47628bcb-21c1-4f80-b068-9148397304f4
