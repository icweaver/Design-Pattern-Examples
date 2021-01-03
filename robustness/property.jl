### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ eea4351a-4da6-11eb-0c95-f3ba4c21ae14
using PlutoUI

# ╔═╡ 14e74e1a-4da7-11eb-0d7b-e5f233f40b5e
md"""
## Lazy file loading
"""

# ╔═╡ 1a1c14c4-4da7-11eb-1194-65d955d8f006
md"""
Take a look at the example file loading implementation below:
"""

# ╔═╡ 3b36c7c4-4da4-11eb-027b-530ceabaa04d
begin
	
mutable struct FileContent
	path
	loaded
	contents
end
function FileContent(path)
	ss = lstat(path)
	return FileContent(path, false, zeros(UInt8, ss.size))
end
	
end

# ╔═╡ 1e239dfe-4da6-11eb-16da-b75a7aefdf4e
function load_contents!(fc::FileContent)
	open(fc.path) do io
		readbytes!(io, fc.contents)
		fc.loaded = true
	end
	return nothing
end

# ╔═╡ 8587434e-4da6-11eb-216d-e370033a06dd
fc = FileContent("/etc/hosts")

# ╔═╡ dd4d8718-4da5-11eb-3e25-9fb29bf3a5c2
fc.loaded

# ╔═╡ b5edd688-4da6-11eb-3c70-517a95da10f1
load_contents!(fc)

# ╔═╡ c59f0398-4da6-11eb-30b2-f5ef05a43794
fc

# ╔═╡ 32cb320c-4da7-11eb-3da4-a368cc73ed19
md"""
`fc` is initialzed with an empty array that is not loaded with actual data until `load_contents!` is called. Now, we need a way to intercept any read operation into the cobntents field so that the content can be loaded lazily (just in time). To do so, we'll need to *hijack* the call to get `fc.contents`.
"""

# ╔═╡ 940b00ba-4da7-11eb-3ebc-f583fd86119f
md"""
## Dot notation and field access
"""

# ╔═╡ c1ace808-4da7-11eb-1ed0-078943188660
md"""
Whenever we access a specfic field of an object via the dot syntax, it's really just syntactic sugar for `getfield`. For example:
"""

# ╔═╡ b18f44b2-4dab-11eb-1738-8b36735e3d99
@code_lowered fc.loaded

# ╔═╡ 1a06a134-4dac-11eb-1f26-6bdf4e2ded26
md"""
It turns out that `Base.getfield` is actually a Julia built-in, which means that it cannot be extended:
"""

# ╔═╡ 2e2b14e0-4dac-11eb-112a-c12098c6d5bf
Base.getfield

# ╔═╡ 5040da80-4dac-11eb-18fa-0b1e9cfb340a
let 
	Base.getfield(fc::FileContent, s::Symbol) = nothing
end

# ╔═╡ 7904ae6a-4dac-11eb-1377-8b5998510a05
md"""
But luckily there are wrapper functions just a level up that we *can* extend:
"""

# ╔═╡ e45ffcaa-4da7-11eb-0143-f987977eb9d6
Meta.lower(Main, :( fc.loaded ))

# ╔═╡ 0cc5a848-4da8-11eb-0140-4fe0b13b1272
md"""
Similarly, `setfield!` is called whenever we modify a field's value:
"""

# ╔═╡ 51d0ad0c-4dad-11eb-1a81-0f3deb13caa3
@code_lowered fc.path = "/etc/hosts"

# ╔═╡ 5cbda742-4dad-11eb-29c3-0df9d6e942f4
md"""
Which is the Julia built-in called by `setproperty!`:
"""

# ╔═╡ 1cf37484-4da8-11eb-2366-fb81d0a99c1a
Meta.lower(Main, :( fc.path = "/etc/hosts" ))

# ╔═╡ f46928a8-4dac-11eb-33c4-41b64186878f
md"""
Now that we know the names of the wrapper functions that are extendable, let's add a method to `getproperty` so that we can control which fields the user will have access to via the dot notation. This will also allow us to lazily load the data only when `.contents` is called:
"""

# ╔═╡ a0b23aba-4daa-11eb-1438-edc2e6311cc9
function load_contents2!(fc::FileContent)
	open(getfield(fc, :path)) do io
		readbytes!(io, getfield(fc, :contents))
		setfield!(fc, :loaded, true)
	end
	return nothing
end

# ╔═╡ e703d4a8-4da8-11eb-3a09-4950168a4227
function Base.getproperty(fc::FileContent, s::Symbol)
	direct_passthrough_fields = (:path, )
	if s in direct_passthrough_fields
		return getfield(fc, s)
	end
	if s === :contents
		getfield(fc, :loaded) || load_contents2!(fc)
		return getfield(fc, :contents)
		# Note: # can wrap in `copy` if data should not be editable
	end
	error("Unsupported property: $s")
end

# ╔═╡ cf02d362-4da9-11eb-2ce5-198fa955a091
fc2 = FileContent("/etc/hosts")

# ╔═╡ 7b212b6c-4daa-11eb-29ac-9318750195b4
fc2.contents

# ╔═╡ 2aef2e92-4dae-11eb-2796-1d21e1fd9603
md"""
The data has been lazily loaded, and the dot syntax to access the fields that we did not specify (`.loaded`) has been successfully closed off to the user:
"""

# ╔═╡ 53340e2c-4dae-11eb-0711-1707209fe515
fc2.loaded

# ╔═╡ 5f20f60a-4dae-11eb-1eff-99fffd3bdd1c
fc2

# ╔═╡ 7e228000-4dae-11eb-183a-db636a4b5b3c
md"""
Finally, we can control write access to our fields by extending `setproperty!`. For example, let's disallow the user from modifying the `contents` field after it has been loaded:
"""

# ╔═╡ de73402a-4dae-11eb-1ba7-894a2344111c
function Base.setproperty!(fc::FileContent, s::Symbol, value)
	if s === :path
		ss = lstat(value)
		setfield!(fc, :path, value)
		setfield!(fc, :loaded, false)
		setfield!(fc, :contents, zeros(UInt8, ss.size))
		println("Object re-initialized for $value (size $(ss.size))")
		return nothing
	end
	error("Property $s cannot be changed.")
end

# ╔═╡ 6a861d9e-4daf-11eb-144f-35c0923da15c
md"""
In addition, the extension above makes it so that only the `path` field is modifiable. This makes it so that everytime the path is updated, the other fields are reset to their initialized state (i.e., `loaded`=false, 'contents'=zeros):
"""

# ╔═╡ 62bbef62-4daf-11eb-293b-a74d2935ff1c
fc2.contents = []

# ╔═╡ a083abd2-4daf-11eb-307b-8d1574f55f9a
with_terminal() do
	fc2.path = "/etc/profile"
end

# ╔═╡ bc43c53c-4daf-11eb-1db5-e592db58935c
fc2

# ╔═╡ 50ddfe20-4db1-11eb-2d5c-eb214dd7969b
md"""
Finally, we can complete the illusion by removing the "private" field `load` from the tab completed list:
"""

# ╔═╡ 698d6fda-4db1-11eb-06bc-b395db558641
Base.propertynames(fc::FileContent) = (:path, :contents)

# ╔═╡ d032220c-4dad-11eb-283c-57b9e7f3ac4e
note(text) = Markdown.MD(Markdown.Admonition("note", "Note", [text]))

# ╔═╡ bd500726-4dad-11eb-2945-159fd5598368
note(
md"""
We are using `get` and `set` fields everywhere instead of using the dot syntax because that calls back to Base, which would then lead us to fall into an infinite loop!
"""
)

# ╔═╡ 28b4bed0-4da7-11eb-0cf2-071444e06846
TableOfContents()

# ╔═╡ Cell order:
# ╟─14e74e1a-4da7-11eb-0d7b-e5f233f40b5e
# ╟─1a1c14c4-4da7-11eb-1194-65d955d8f006
# ╠═3b36c7c4-4da4-11eb-027b-530ceabaa04d
# ╠═1e239dfe-4da6-11eb-16da-b75a7aefdf4e
# ╠═8587434e-4da6-11eb-216d-e370033a06dd
# ╠═dd4d8718-4da5-11eb-3e25-9fb29bf3a5c2
# ╠═b5edd688-4da6-11eb-3c70-517a95da10f1
# ╠═c59f0398-4da6-11eb-30b2-f5ef05a43794
# ╟─32cb320c-4da7-11eb-3da4-a368cc73ed19
# ╟─940b00ba-4da7-11eb-3ebc-f583fd86119f
# ╟─c1ace808-4da7-11eb-1ed0-078943188660
# ╠═b18f44b2-4dab-11eb-1738-8b36735e3d99
# ╟─1a06a134-4dac-11eb-1f26-6bdf4e2ded26
# ╠═2e2b14e0-4dac-11eb-112a-c12098c6d5bf
# ╠═5040da80-4dac-11eb-18fa-0b1e9cfb340a
# ╟─7904ae6a-4dac-11eb-1377-8b5998510a05
# ╠═e45ffcaa-4da7-11eb-0143-f987977eb9d6
# ╟─0cc5a848-4da8-11eb-0140-4fe0b13b1272
# ╠═51d0ad0c-4dad-11eb-1a81-0f3deb13caa3
# ╟─5cbda742-4dad-11eb-29c3-0df9d6e942f4
# ╠═1cf37484-4da8-11eb-2366-fb81d0a99c1a
# ╟─f46928a8-4dac-11eb-33c4-41b64186878f
# ╠═e703d4a8-4da8-11eb-3a09-4950168a4227
# ╠═a0b23aba-4daa-11eb-1438-edc2e6311cc9
# ╟─bd500726-4dad-11eb-2945-159fd5598368
# ╠═cf02d362-4da9-11eb-2ce5-198fa955a091
# ╠═7b212b6c-4daa-11eb-29ac-9318750195b4
# ╟─2aef2e92-4dae-11eb-2796-1d21e1fd9603
# ╠═53340e2c-4dae-11eb-0711-1707209fe515
# ╠═5f20f60a-4dae-11eb-1eff-99fffd3bdd1c
# ╟─7e228000-4dae-11eb-183a-db636a4b5b3c
# ╠═de73402a-4dae-11eb-1ba7-894a2344111c
# ╟─6a861d9e-4daf-11eb-144f-35c0923da15c
# ╠═62bbef62-4daf-11eb-293b-a74d2935ff1c
# ╠═a083abd2-4daf-11eb-307b-8d1574f55f9a
# ╠═bc43c53c-4daf-11eb-1db5-e592db58935c
# ╟─50ddfe20-4db1-11eb-2d5c-eb214dd7969b
# ╠═698d6fda-4db1-11eb-06bc-b395db558641
# ╟─d032220c-4dad-11eb-283c-57b9e7f3ac4e
# ╠═28b4bed0-4da7-11eb-0cf2-071444e06846
# ╠═eea4351a-4da6-11eb-0c95-f3ba4c21ae14
