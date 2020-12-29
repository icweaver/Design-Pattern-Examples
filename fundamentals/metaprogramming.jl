### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ cffa6536-47bf-11eb-1ff1-19b3ecc5bdba
using Unrolled

# ╔═╡ 31fc2306-47c4-11eb-36ae-9d59c174cee1
using PlutoUI

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

# ╔═╡ 1ca9b21a-47c5-11eb-24ff-45d0edc179e1
md"""
Julia provides a nice way of taking a look at the AST representation of source code, which we can parse as a `String`:
"""

# ╔═╡ 47cba528-47c2-11eb-342b-61f21c8a8a2f
expr = Meta.parse("x + y")

# ╔═╡ 2d06f6c8-47c4-11eb-2b44-bbb193ecfc93
with_terminal() do
	dump(expr)
end

# ╔═╡ 6bfc34d2-47c5-11eb-297e-ade03db28bff
md"""
Or directly as an `Expr`:
"""

# ╔═╡ 5f69e760-47c4-11eb-0ac9-81fa46413ea2
with_terminal() do
	dump(:(x + 2*y))
end

# ╔═╡ e4f003b4-47c5-11eb-1d65-83e072fd54f4
md"""
We can also build multi-line expressions by wrapping them in a `quote` block:
"""

# ╔═╡ 9b97fcb4-47c8-11eb-21ff-edfd507337c4
md"""
And write our own macros by doing the following:
"""

# ╔═╡ e4d862e0-47c5-11eb-137c-218daa0eb24d
macro hello(n)
	return :(
		for i in 1:$n
			println("hello world")
		end
	)
end

# ╔═╡ e4a9a37e-47c5-11eb-336a-9569899172f0
with_terminal() do
	@hello 3
end

# ╔═╡ ba334ec0-47c9-11eb-3de8-af71c89192cd
md"""
We can also inspect our macro by doing the following:
"""

# ╔═╡ cb8f3f08-47c9-11eb-3323-b7cf6dd3011c
@macroexpand @hello 3

# ╔═╡ ee3dd1a2-47cb-11eb-00b5-61e8efe69eed
md"""
### Scope
"""

# ╔═╡ f7efc6ec-47cb-11eb-1a73-2ba344495bdf
md"""
Let's take a look at the following:
"""

# ╔═╡ e1c13a82-47c5-11eb-14b8-2f0e891df02a
macro doubled(ex)
	return :( 2 * $(ex) )
end

# ╔═╡ 05d14268-47ca-11eb-2d34-837739cf8afc
function foo()
	h = 4
	return @doubled h
end

# ╔═╡ ec56fc3a-47c9-11eb-14ae-47a75b3cc495
foo()

# ╔═╡ 37e4de06-47ca-11eb-3fa1-535ef99fab77
md"""
Why did this throw an `UndefVarError`? Let's take a look at the lowered code:
"""

# ╔═╡ 4f682b9e-47ca-11eb-070a-8f90bbdf8490
@code_lowered foo()

# ╔═╡ c1374c5c-47ca-11eb-0a3c-fb174e959a40
md"""
Ah, this is trying to use a global `h` instead of local. We can keep the compiler from resolving `ex`, and instead place it directly in the expression tree by using the `esc` command:
"""

# ╔═╡ 85701898-47ca-11eb-3e3c-0f381328787f
macro doubled_esc(ex)
	return :( 2 * $(esc(ex)) )
end

# ╔═╡ b3974600-47cb-11eb-2ecf-310498a79759
function foo2()
	h = 4
	return @doubled_esc h
end

# ╔═╡ 1cf56538-47cb-11eb-28cd-1d9a64faa117
foo2()

# ╔═╡ 920012f2-47ca-11eb-3ebc-573c92ea02ce
@code_lowered foo2()

# ╔═╡ 3121adea-47cc-11eb-08be-49cb094afc6c
md"""
### Generated function
"""

# ╔═╡ 36ca576a-47cc-11eb-26dd-31e32083c232
md"""
This is all well and good, but macros only work at the syntax level, so everything just looks like an `Expr`. We have no access to the type of what the expression represents, so for example if we wanted to extend our macro to switch to some new optimized method based on the type the input passed to it, it would fail:
```julia
	macro doubled_esc(ex)
		if typeof(ex) isa AbstractFloat
			return : ( super_optimized_functions_for_floats($(esc(ex))) )
		else:	
			return :( 2 * $(esc(ex)) )
		end
	end
```
"""

# ╔═╡ 664249b6-47cd-11eb-076d-21c8409f18ff
md"""
This is where generated functions come in.
"""

# ╔═╡ 92a94ed2-47cd-11eb-389b-db76e5dddfa8
 @generated function doubled(x)
        if x <: AbstractFloat
            return :("Super optimized float input return")
        else
            return :( 2 * x )
        end
    end

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
# ╟─1ca9b21a-47c5-11eb-24ff-45d0edc179e1
# ╠═47cba528-47c2-11eb-342b-61f21c8a8a2f
# ╠═2d06f6c8-47c4-11eb-2b44-bbb193ecfc93
# ╟─6bfc34d2-47c5-11eb-297e-ade03db28bff
# ╠═5f69e760-47c4-11eb-0ac9-81fa46413ea2
# ╟─e4f003b4-47c5-11eb-1d65-83e072fd54f4
# ╟─9b97fcb4-47c8-11eb-21ff-edfd507337c4
# ╠═e4d862e0-47c5-11eb-137c-218daa0eb24d
# ╠═e4a9a37e-47c5-11eb-336a-9569899172f0
# ╟─ba334ec0-47c9-11eb-3de8-af71c89192cd
# ╠═cb8f3f08-47c9-11eb-3323-b7cf6dd3011c
# ╟─ee3dd1a2-47cb-11eb-00b5-61e8efe69eed
# ╟─f7efc6ec-47cb-11eb-1a73-2ba344495bdf
# ╠═e1c13a82-47c5-11eb-14b8-2f0e891df02a
# ╠═05d14268-47ca-11eb-2d34-837739cf8afc
# ╠═ec56fc3a-47c9-11eb-14ae-47a75b3cc495
# ╟─37e4de06-47ca-11eb-3fa1-535ef99fab77
# ╠═4f682b9e-47ca-11eb-070a-8f90bbdf8490
# ╟─c1374c5c-47ca-11eb-0a3c-fb174e959a40
# ╠═85701898-47ca-11eb-3e3c-0f381328787f
# ╠═b3974600-47cb-11eb-2ecf-310498a79759
# ╠═1cf56538-47cb-11eb-28cd-1d9a64faa117
# ╠═920012f2-47ca-11eb-3ebc-573c92ea02ce
# ╟─3121adea-47cc-11eb-08be-49cb094afc6c
# ╟─36ca576a-47cc-11eb-26dd-31e32083c232
# ╟─664249b6-47cd-11eb-076d-21c8409f18ff
# ╠═92a94ed2-47cd-11eb-389b-db76e5dddfa8
# ╠═31fc2306-47c4-11eb-36ae-9d59c174cee1
