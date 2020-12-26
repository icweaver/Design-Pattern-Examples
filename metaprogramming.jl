### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ cffa6536-47bf-11eb-1ff1-19b3ecc5bdba
using Unrolled

# ╔═╡ 81d39f16-47c0-11eb-045a-617691909b03
md"""
## A few cases for metaprogramming
"""

# ╔═╡ 395ee828-47be-11eb-0f15-55d754d1c549
md"""
99% of the time, we don't really need to use macros. For that 1% of the time though, it can come in handy. For example, timing things:

```julia
@time sum(rand(10_000_000))
```

is a lot more convenient to write than the following pseudo-code:

```julia
mycode() = sum(rand(10_000_000))
time(mycode)
```
"""

# ╔═╡ b2d11256-47c0-11eb-1fb6-d9eaf7d1c7d0
md"""
Another example is loop unrolling. If we already know how long a loop needs to iterate for:
"""

# ╔═╡ a233b1ac-47bf-11eb-328f-63e01863cc8c
function hello_loop()
	for i in 1:3
		println("hello: $i")
	end
end

# ╔═╡ 59fd17a6-47c0-11eb-2b5f-811592bc1667
@code_lowered hello_loop()

# ╔═╡ de6ab584-47c0-11eb-338d-d3d27f53701a
md"""
Then we can avoid relying on those checking of conditionals and applying `goto` instructions above by explicity writing each `println` statement:
"""

# ╔═╡ d9a9eeb4-47bf-11eb-1004-2bdf62014317
@unroll function hello_unrolled(xs)
	@unroll for i in xs
		println("hello: $i")
	end
end

# ╔═╡ fd0ceada-47bf-11eb-34c9-93a976bf4472
seq = tuple(1:3...)

# ╔═╡ 0949c624-47c0-11eb-374a-5132e5073c78
@code_lowered hello_unrolled(seq)

# ╔═╡ 2f8544e0-47c2-11eb-21a4-63f4135b8a91
md"""
## Working with expressions
"""

# ╔═╡ 47cba528-47c2-11eb-342b-61f21c8a8a2f


# ╔═╡ Cell order:
# ╟─81d39f16-47c0-11eb-045a-617691909b03
# ╟─395ee828-47be-11eb-0f15-55d754d1c549
# ╟─b2d11256-47c0-11eb-1fb6-d9eaf7d1c7d0
# ╠═a233b1ac-47bf-11eb-328f-63e01863cc8c
# ╠═59fd17a6-47c0-11eb-2b5f-811592bc1667
# ╟─de6ab584-47c0-11eb-338d-d3d27f53701a
# ╠═cffa6536-47bf-11eb-1ff1-19b3ecc5bdba
# ╠═d9a9eeb4-47bf-11eb-1004-2bdf62014317
# ╠═fd0ceada-47bf-11eb-34c9-93a976bf4472
# ╠═0949c624-47c0-11eb-374a-5132e5073c78
# ╟─2f8544e0-47c2-11eb-21a4-63f4135b8a91
# ╠═47cba528-47c2-11eb-342b-61f21c8a8a2f
