### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 9f45d81a-48a4-11eb-1bbf-8f8dc78a0a1f
using PlutoUI, BenchmarkTools

# ╔═╡ 4025e70a-48a5-11eb-280e-03f4cf0065d9
md"""
##### Don't use global variables
"""

# ╔═╡ 4bd50410-48a4-11eb-15df-794a1d195e65
variable = 10

# ╔═╡ 9653a668-48a4-11eb-1573-fff81414b9e1
function add_using_global_variable(x)
	return x + variable
end

# ╔═╡ e924ae82-48a4-11eb-1d62-93350ce977c8
with_terminal() do
	@btime add_using_global_variable(10)
end

# ╔═╡ 1359672e-48a5-11eb-2376-414aaebc273f
function add_using_function_arg(x, y)
	return x + y
end

# ╔═╡ 1e8f3588-48a5-11eb-0de1-6fcb0533fb06
with_terminal() do
	@btime add_using_function_arg(10, 10)
end

# ╔═╡ 3e589832-48a5-11eb-3afa-f9a6f88605ed
md"""
That's a lot faster. Let's take a look at the llvm:
"""

# ╔═╡ 644d551e-48a5-11eb-2714-7f4856f51ba9
with_terminal() do
	@code_llvm add_using_global_variable(10)
end

# ╔═╡ 985fe206-48a5-11eb-0b73-8539e699ffd5
md"""
That... is a lot of instructions for just adding together two numbers. How about for the function version?
"""

# ╔═╡ a54aa06c-48a5-11eb-3f57-1d66fb6f64d2
with_terminal() do
	@code_llvm add_using_function_arg(10, 10)
end

# ╔═╡ beedf302-48a5-11eb-1751-7d3f7d3560a3
md"""
WOW. Why is the global version so much worse? Well, because it has to deal with a global variable, the compiler cannot assume its type, so it needs to generate all of those extra instructions to deal with that. On the other hand, the function version lets the compiler infer the type ahead of time and use the appropriate set of instructions!
"""

# ╔═╡ 712e2c94-48a6-11eb-328d-c5630d27f886
md"""
##### If you have to use globals, make them constants
"""

# ╔═╡ 7f30bf44-48a6-11eb-1b04-df6d5cc96b1a
const const_variable = 10

# ╔═╡ 158abfa4-48bc-11eb-0eae-399b5dbc3c3d
function add_using_global_const(x)
	return x + const_variable
end

# ╔═╡ 0128d76c-48bc-11eb-39f0-b5b6157763c8
with_terminal() do
	@btime add_using_global_const(10)
end

# ╔═╡ 3c45fc08-48bc-11eb-2a6f-97fd4325bb13
with_terminal() do
	@code_llvm add_using_global_const(10)
end

# ╔═╡ 23d88174-4991-11eb-2592-ffc280f06e45
md"""
##### If you need your global var to be able to change later, use type annotations
"""

# ╔═╡ 913d978e-48bc-11eb-1669-e98edd2a0927
var = 10

# ╔═╡ a160b786-48bc-11eb-3240-b187e96a7c4e
function add_using_global_variable_typed(x)
	return x + var::Int
end

# ╔═╡ cf542ccc-48bc-11eb-171a-e1d74d85d6fd
with_terminal() do
	@btime add_using_global_variable_typed(10)
end

# ╔═╡ 624cf57a-4991-11eb-2194-ade4c534187c
md"""
This is faster than the untyped version, but still slower than making it a const or just making it part of the function. Now let's see why using constants are so nice:
"""

# ╔═╡ c690ce26-4991-11eb-00ed-8733cd47af02
function constant_folding_example()
	a = 2 * 3
	b = a + 1
	return b > 1 ? 10 : 20
end

# ╔═╡ 624a418a-4992-11eb-186a-375bb7473257
md"""
Using `@code_typed` we can take a look at the code after all of the type information has been resolved by the compiler:
"""

# ╔═╡ d4f1c498-4991-11eb-08ec-bdb3e8f74ffd
@code_typed constant_folding_example()

# ╔═╡ d52d445a-4991-11eb-36af-0b830ee2d696
md"""
A couple things have happened:

* `a` = 6 was computed from the two constants `2` and `3` (constant folding)

* `b` = 7 was then computed from the compiler inferring that `a` = 6 (constant propogation)

* The `else` branch ` : 20` was then pruned away (dead code elimination)

"""

# ╔═╡ 1923fef8-4995-11eb-17ac-8be3cede99ef
md"""
##### Passing global variables as function arguments
"""

# ╔═╡ 54fb43aa-4995-11eb-0e2e-1371e22b4999
md"""
Another thing we can do is pass the global variable as an arg to our function, instead of hard-coding it like earlier:
"""

# ╔═╡ 19af7ae6-4995-11eb-1267-dfe92d17e97e
function add_by_passing_global_variable(x, v)
	return x + v
end

# ╔═╡ 19c3ae1c-4995-11eb-1b7e-b3bfc8499dc5
with_terminal() do
	@btime add_by_passing_global_variable(10, $var)
end

# ╔═╡ 2b6eca0c-4995-11eb-176d-67bec8b8559c
md"""
Bam, it's as fast as our constant example.
"""

# ╔═╡ 2b833fbe-4995-11eb-1942-9d9f9870a99c
const semi_constant = Ref(10)

# ╔═╡ 52df081a-4996-11eb-15e9-718bc8a44c2f
function add_using_global_semi_constant(x)
	return x + semi_constant[] # [] fetches the value stored inside a `Ref`object
end

# ╔═╡ 6725d50a-4996-11eb-1956-b190bb64f5e2
with_terminal() do
	@btime add_using_global_semi_constant(10)
end

# ╔═╡ d04a9e60-4996-11eb-0f00-fd11850919fb
md"""
Not as fast as our constant case, but still much faster than the global case! In summary:
"""

# ╔═╡ dc1967b2-4996-11eb-240b-059d6c7143d3
with_terminal() do
	@btime add_using_global_variable(10)
	@btime add_using_global_variable_typed(10)
	@btime add_using_global_semi_constant(10)
	@btime add_using_global_const(10)
	@btime add_by_passing_global_variable(10, $var)
	@btime add_using_function_arg(10, 10)
end

# ╔═╡ Cell order:
# ╟─4025e70a-48a5-11eb-280e-03f4cf0065d9
# ╠═4bd50410-48a4-11eb-15df-794a1d195e65
# ╠═9653a668-48a4-11eb-1573-fff81414b9e1
# ╠═e924ae82-48a4-11eb-1d62-93350ce977c8
# ╠═1359672e-48a5-11eb-2376-414aaebc273f
# ╠═1e8f3588-48a5-11eb-0de1-6fcb0533fb06
# ╟─3e589832-48a5-11eb-3afa-f9a6f88605ed
# ╠═644d551e-48a5-11eb-2714-7f4856f51ba9
# ╟─985fe206-48a5-11eb-0b73-8539e699ffd5
# ╠═a54aa06c-48a5-11eb-3f57-1d66fb6f64d2
# ╟─beedf302-48a5-11eb-1751-7d3f7d3560a3
# ╟─712e2c94-48a6-11eb-328d-c5630d27f886
# ╠═7f30bf44-48a6-11eb-1b04-df6d5cc96b1a
# ╠═158abfa4-48bc-11eb-0eae-399b5dbc3c3d
# ╠═0128d76c-48bc-11eb-39f0-b5b6157763c8
# ╠═3c45fc08-48bc-11eb-2a6f-97fd4325bb13
# ╟─23d88174-4991-11eb-2592-ffc280f06e45
# ╠═913d978e-48bc-11eb-1669-e98edd2a0927
# ╠═a160b786-48bc-11eb-3240-b187e96a7c4e
# ╠═cf542ccc-48bc-11eb-171a-e1d74d85d6fd
# ╟─624cf57a-4991-11eb-2194-ade4c534187c
# ╠═c690ce26-4991-11eb-00ed-8733cd47af02
# ╟─624a418a-4992-11eb-186a-375bb7473257
# ╠═d4f1c498-4991-11eb-08ec-bdb3e8f74ffd
# ╟─d52d445a-4991-11eb-36af-0b830ee2d696
# ╟─1923fef8-4995-11eb-17ac-8be3cede99ef
# ╟─54fb43aa-4995-11eb-0e2e-1371e22b4999
# ╠═19af7ae6-4995-11eb-1267-dfe92d17e97e
# ╠═19c3ae1c-4995-11eb-1b7e-b3bfc8499dc5
# ╟─2b6eca0c-4995-11eb-176d-67bec8b8559c
# ╠═2b833fbe-4995-11eb-1942-9d9f9870a99c
# ╠═52df081a-4996-11eb-15e9-718bc8a44c2f
# ╠═6725d50a-4996-11eb-1956-b190bb64f5e2
# ╟─d04a9e60-4996-11eb-0f00-fd11850919fb
# ╠═dc1967b2-4996-11eb-240b-059d6c7143d3
# ╠═9f45d81a-48a4-11eb-1bbf-8f8dc78a0a1f
