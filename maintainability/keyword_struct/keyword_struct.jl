### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 0e88cf44-4d66-11eb-2b9b-592f5df19215
md"""
Say we want to have a struct containing different text attribute:

```julia
struct TextStyle
	font_family
	font_size
	font_weight
	foreground_color
	background_color
	alignment
	rotation
end
```

This is sort of a pain to deal with, because everytime we want to use it, we have to remember the order of each field. There's also no easy way to set default values for some of the fields out of the box. We could define a constructor like:

```julia
function TextStyle(;
	font_family,
	font_size,
	font_weight = "Normal",
	...
)
```

but then we'd have to do that everytime we want to define a struct with keyword fields. We're also duplicating all of the field names just to add this little bit of functionality, which violates the DRY principle. "There's got to be a better way"

Enter: `@kwdef`
"""

# ╔═╡ 00864ba2-4d65-11eb-0055-8f5b91551f97
Base.@kwdef struct TextStyle
	font_family
	font_size
	font_weight = "Normal"
	foreground_color = "black"
	background_color = "white"
	alignment = "center"
	rotation = 0
end

# ╔═╡ 67fb78be-4d67-11eb-16b3-d3efac3ac327
md"""
If we take a look at the methods now, we see that a keyword version has been automatically constructed for us!
"""

# ╔═╡ 3d041120-4d67-11eb-1df7-15b4e7855ff3
methods(TextStyle)

# ╔═╡ 79d06892-4d67-11eb-271e-cb5d83137b5d
md"""
Note that the fields without any assignments are treated as mandatory named args. Now, creating new `TextStyle` objects is as easy as:
"""

# ╔═╡ 44ffdcf8-4d65-11eb-1eee-7129f992b24a
style = TextStyle(
	font_family="Arial",
	font_size=10,
)

# ╔═╡ Cell order:
# ╠═0e88cf44-4d66-11eb-2b9b-592f5df19215
# ╠═00864ba2-4d65-11eb-0055-8f5b91551f97
# ╟─67fb78be-4d67-11eb-16b3-d3efac3ac327
# ╠═3d041120-4d67-11eb-1df7-15b4e7855ff3
# ╟─79d06892-4d67-11eb-271e-cb5d83137b5d
# ╠═44ffdcf8-4d65-11eb-1eee-7129f992b24a
