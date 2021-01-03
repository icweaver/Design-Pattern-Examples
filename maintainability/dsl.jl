### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ b733a398-4d8f-11eb-18b2-451ff9c3a648
using PlutoUI, MacroTools, AbstractTrees

# ╔═╡ 9c12d53e-4d8f-11eb-3c83-a998838b9778
md"""
# Algae L-System
"""

# ╔═╡ 658e2aa4-4d91-11eb-2fcc-59be3bd608ed
md"""
## Overview
"""

# ╔═╡ c5c291b2-4d8f-11eb-3bfb-1d288c92c1f4
md"""
Say we have an algae system that is written like this in our algae science domain:

```julia
Axiom: A
	Rule: A → AB
	Rule: B → A
```
"""

# ╔═╡ 16898d3a-4d90-11eb-2145-f1f2adc65741
md"""
that we would like to model in Julia with syntax that is as similar to the above schematic as possible. We could write something like this in plain Julia:

```julia
model = LModel("A")
add_rule!(model, "A", "AB")
add_rule!(model, "B", "A")
```

It's not terrible, but wouldn't it be great as an algae scientist if we could instead write something like this to be more in-line with the conventions of our particular field?:

```julia
model = @lsys begin
	axiom : A
	rule  : A → AB
	ruke  : B → A
end
```

Let's do it.
"""

# ╔═╡ 2b8eb328-4d91-11eb-3f8a-f70e8290fd0a
md"""
## Implementation
"""

# ╔═╡ 32031628-4d91-11eb-06d4-b1c340f932f4
md"""
Under the hood, our DSL is still plain Julia, so let's start writing that out:
"""

# ╔═╡ 66eab42c-4d93-11eb-015d-cf91386f06c9
md"""
### `LModel` object
"""

# ╔═╡ 81ab13e4-4d91-11eb-0ef0-4bdfbe1a99fe
begin
struct LModel
	axiom
	rules
end

# Create an L-system model
LModel(axiom) = LModel([axiom], Dict())
end

# ╔═╡ d792358a-4d91-11eb-2065-81121bafe949
# Add rule to model
function add_rule!(model::LModel, left::T, right::T) where {T <: AbstractString}
	# Convert string to array of characters and assign to rules dict
	model.rules[left] = split(right, "")
	return nothing
end

# ╔═╡ aad9e1e6-4d91-11eb-1b80-5f506caa8380
# Custom display for LModel struct
function Base.show(io::IO, model::LModel)
	println(io, "LModel:")
	println(io, " Axiom: ", join(model.axiom))
	for k in sort(collect(keys(model.rules)))
		println(io, " Rule: ", k, " → ", join(model.rules[k]))
	end
end

# ╔═╡ 8bc4b750-4d92-11eb-3614-070eab5afed2
algae_model = LModel("A")

# ╔═╡ 931c7180-4d92-11eb-2a0b-f771f00f52d0
add_rule!(algae_model, "A", "AB")

# ╔═╡ 9db9ae00-4d92-11eb-2fce-496ef1e7edca
add_rule!(algae_model, "B", "A")

# ╔═╡ 191f6dc8-4d93-11eb-12f8-b5bf10fe003b
algae_model

# ╔═╡ ed388e94-4d95-11eb-06a6-393a4938c38c
md"""
### `LState` object
"""

# ╔═╡ 79401054-4d93-11eb-01fc-1117f7ec0763
md"""
Now that we developed this object, let's develop its state next. This is how our DSL will keep track of the current state of the iteration:
"""

# ╔═╡ 9db3798c-4d93-11eb-31a6-c30c879800e1
begin
struct LState
	model
	current_iteration
	result
end

# Create an L_system state from a `model`
LState(model::LModel) = LState(model, 1, model.axiom)
end

# ╔═╡ d674c396-4d93-11eb-36f4-29651e80ff6c
md"""
We need a function to advance to the next stage of the algae growth:
"""

# ╔═╡ f60560bc-4d93-11eb-070d-05aff8e7a12e
function next(state::LState)
	new_result = []
	for el in state.result
		# Look up `el` from the rules dictionary and append to `new_result`
		# Just default to the element itself when it is not found
        next_elements = get(state.model.rules, el, el)
        append!(new_result, next_elements)
	end
	return LState(state.model, state.current_iteration + 1, new_result)
end

# ╔═╡ 469f5b90-4d94-11eb-16c7-e94bdbf44d5b
md"""
And let's also add a custom display for the state object:
"""

# ╔═╡ 608ffe42-4d94-11eb-3f8c-031ee20cb4a6
result(state::LState) = join(state.result)

# ╔═╡ 79fac538-4d94-11eb-3cbd-a5682555abc1
function Base.show(io::IO, s::LState)
	print(io, "LState($(s.current_iteration)): $(result(s))")
end

# ╔═╡ a5db8174-4d94-11eb-284a-5becd77fe0c7
state = LState(algae_model)

# ╔═╡ ad18b5b0-4d94-11eb-0465-0b09cb74efdf
state2 = next(state)

# ╔═╡ c9332ac8-4d94-11eb-32d1-f1c0cc76dcb8
state3 = next(state2)

# ╔═╡ cd1ecdce-4d95-11eb-3ca5-e710199cd598
state4 = next(state3)

# ╔═╡ 052d16be-4d96-11eb-0da5-136dca121474
md"""
Ok, the core logic looks to be in place! Now to implement the DSL.
"""

# ╔═╡ 1334cc40-4d96-11eb-04b4-19bee0aaf59f
md"""
### DSL for L-System
"""

# ╔═╡ 67e1cc9e-4d96-11eb-148b-dd6119e5a0e0
md"""
We will accomplish this with the `MacroTools` package. Some quick background:
"""

# ╔═╡ b9075f6e-4d96-11eb-3a6e-df365c9447a2
md"""
You can extract data from a symbol by doing pattern matching. Whatever has an underscore suffix will be extracted in the matching:
"""

# ╔═╡ 1d560b9c-4d96-11eb-0fff-7d73e940f8d6
@capture( :( x = 1), x = val_)

# ╔═╡ 5ff5ac96-4d96-11eb-2ac3-a3730e8189cd
val

# ╔═╡ d939fd1e-4d96-11eb-27e4-9f930994d0ef
ex = :( rule : A → AB )

# ╔═╡ fc91eb00-4d96-11eb-1833-dff62d007d5b
@capture(ex, rule : original_ → replacement_)

# ╔═╡ 0b59b064-4d97-11eb-227d-c920b2f94c95
original, replacement

# ╔═╡ 6079cabe-4d99-11eb-0645-8dd536eb699e
md"""
You can also walk through the entire AST like so:
"""

# ╔═╡ a9bf4052-4d97-11eb-21d6-6f770cb5acd1
ex2 = quote
	x = 1
	y = x^2 + 3
end |> rmlines

# ╔═╡ d1dda274-4d97-11eb-2619-975688d7f477
with_terminal() do
	MacroTools.postwalk(x -> @show(x), ex2)
end

# ╔═╡ 70f7b740-4d99-11eb-0c60-f551f9f26269
md"""
With these tools in hand, let's build the macro for our DSL.
"""

# ╔═╡ 7dcfa084-4d99-11eb-0915-43c192a85615
md"""
### DSL macro
"""

# ╔═╡ 9a96ecae-4d99-11eb-1514-0791f3691cef
md"""
To do this, we'll need a `walk` function to pass to `postwalk`:
"""

# ╔═╡ c348d8f6-4d99-11eb-3215-99eb113e5359
function walk(ex)
	match_axiom = @capture(ex, axiom : sym_)
	if match_axiom
		sym_str = String(sym)
		return :( model = LModel($sym_str) )
	end
	
	match_rule = @capture(ex, rule : original_ → replacement_)
	if match_rule
		original_str = String(original)
		replacement_str = String(replacement)
		return :( add_rule!(model, $original_str, $replacement_str) )
	end
	
	return ex
end

# ╔═╡ 02e5281a-4d9b-11eb-0df9-cb89ad746b3f
let
	ex = quote
		axiom : A
		rule  : A → AB
		rule  : B → A
	end
	MacroTools.postwalk(walk, ex) |> rmlines
end

# ╔═╡ 87fae7d0-4d99-11eb-0f6e-5dad00e53fd6
macro lsys(ex)
	ex = MacroTools.postwalk(walk, ex)
	push!(ex.args, :( model ))
	return ex
end

# ╔═╡ 96b93fe2-4d99-11eb-20eb-8be1e35976c0
@macroexpand(
	algae_model2 = @lsys begin
	axiom : A
	rule  : A → AB
	rule  : B → A
	end
) |> rmlines

# ╔═╡ bf442846-4d8f-11eb-3102-6bb13880a470
PlutoUI.TableOfContents()

# ╔═╡ Cell order:
# ╟─9c12d53e-4d8f-11eb-3c83-a998838b9778
# ╟─658e2aa4-4d91-11eb-2fcc-59be3bd608ed
# ╟─c5c291b2-4d8f-11eb-3bfb-1d288c92c1f4
# ╟─16898d3a-4d90-11eb-2145-f1f2adc65741
# ╟─2b8eb328-4d91-11eb-3f8a-f70e8290fd0a
# ╟─32031628-4d91-11eb-06d4-b1c340f932f4
# ╟─66eab42c-4d93-11eb-015d-cf91386f06c9
# ╠═81ab13e4-4d91-11eb-0ef0-4bdfbe1a99fe
# ╠═d792358a-4d91-11eb-2065-81121bafe949
# ╠═aad9e1e6-4d91-11eb-1b80-5f506caa8380
# ╠═8bc4b750-4d92-11eb-3614-070eab5afed2
# ╠═931c7180-4d92-11eb-2a0b-f771f00f52d0
# ╠═9db9ae00-4d92-11eb-2fce-496ef1e7edca
# ╠═191f6dc8-4d93-11eb-12f8-b5bf10fe003b
# ╟─ed388e94-4d95-11eb-06a6-393a4938c38c
# ╟─79401054-4d93-11eb-01fc-1117f7ec0763
# ╠═9db3798c-4d93-11eb-31a6-c30c879800e1
# ╟─d674c396-4d93-11eb-36f4-29651e80ff6c
# ╠═f60560bc-4d93-11eb-070d-05aff8e7a12e
# ╟─469f5b90-4d94-11eb-16c7-e94bdbf44d5b
# ╠═608ffe42-4d94-11eb-3f8c-031ee20cb4a6
# ╠═79fac538-4d94-11eb-3cbd-a5682555abc1
# ╠═a5db8174-4d94-11eb-284a-5becd77fe0c7
# ╠═ad18b5b0-4d94-11eb-0465-0b09cb74efdf
# ╠═c9332ac8-4d94-11eb-32d1-f1c0cc76dcb8
# ╠═cd1ecdce-4d95-11eb-3ca5-e710199cd598
# ╟─052d16be-4d96-11eb-0da5-136dca121474
# ╟─1334cc40-4d96-11eb-04b4-19bee0aaf59f
# ╟─67e1cc9e-4d96-11eb-148b-dd6119e5a0e0
# ╟─b9075f6e-4d96-11eb-3a6e-df365c9447a2
# ╠═1d560b9c-4d96-11eb-0fff-7d73e940f8d6
# ╠═5ff5ac96-4d96-11eb-2ac3-a3730e8189cd
# ╠═d939fd1e-4d96-11eb-27e4-9f930994d0ef
# ╠═fc91eb00-4d96-11eb-1833-dff62d007d5b
# ╠═0b59b064-4d97-11eb-227d-c920b2f94c95
# ╟─6079cabe-4d99-11eb-0645-8dd536eb699e
# ╠═a9bf4052-4d97-11eb-21d6-6f770cb5acd1
# ╠═d1dda274-4d97-11eb-2619-975688d7f477
# ╟─70f7b740-4d99-11eb-0c60-f551f9f26269
# ╟─7dcfa084-4d99-11eb-0915-43c192a85615
# ╟─9a96ecae-4d99-11eb-1514-0791f3691cef
# ╠═c348d8f6-4d99-11eb-3215-99eb113e5359
# ╠═02e5281a-4d9b-11eb-0df9-cb89ad746b3f
# ╠═87fae7d0-4d99-11eb-0f6e-5dad00e53fd6
# ╠═96b93fe2-4d99-11eb-20eb-8be1e35976c0
# ╠═bf442846-4d8f-11eb-3102-6bb13880a470
# ╠═b733a398-4d8f-11eb-18b2-451ff9c3a648
