### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ d6f109f2-44f0-11eb-3e35-15b3f05183e6
using PlutoUI

# ╔═╡ 2fc59f0e-44ef-11eb-1796-c32730956f13
convert(Float64, 1)

# ╔═╡ 529ac2b4-44f1-11eb-1676-91a6bf946b69
md"""
Under the hood, this is doing the following:

```julia
convert(::Type{T}, x::Number) where {T<:Number} = T(x)
```

Since we don't care about assigning a variable name to the first arg and its not an instance of a type, it's just `::Type{T}`, instead of something like `foo::Type{T}`. The `{T}` is also added to make sure that the type being passed as the first arg is a subtype of `Number`.

Thanks to multiple dispatch, there is also a second `convert` function that handles the case where `x` happens to be the same type as what you want we want to convert it to:

```julia
	my_convert(::Type{T}, x::T) where {T<:Number} = x
```

It saves the extra step of doing an unecessary call to the constructor `T(x)` and just returns the `Number` back to us. Yay optimization!
"""

# ╔═╡ a93cd91c-44f2-11eb-10e3-95744cd40f77
with_terminal() do
	println("First example:")
	println(@code_lowered convert(Float64, 1))
	println("\nSecond example:")
	println(@code_lowered convert(Float64, 1.))
end

# ╔═╡ Cell order:
# ╠═2fc59f0e-44ef-11eb-1796-c32730956f13
# ╟─529ac2b4-44f1-11eb-1676-91a6bf946b69
# ╠═a93cd91c-44f2-11eb-10e3-95744cd40f77
# ╠═d6f109f2-44f0-11eb-3e35-15b3f05183e6
