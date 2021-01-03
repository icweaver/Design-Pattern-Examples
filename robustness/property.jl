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
Whenever we access a specfic field of an object via the dot syntax, it's really just syntactic sugar for `getproperty`. For example:
"""

# ╔═╡ e45ffcaa-4da7-11eb-0143-f987977eb9d6
Meta.lower(Main, :( fc.loaded ))

# ╔═╡ adbb26c0-4da7-11eb-2cdc-7dbf5639fb0c
fc.loaded === getproperty(fc, :loaded)

# ╔═╡ 0cc5a848-4da8-11eb-0140-4fe0b13b1272
md"""
Similarly, `setproperty!` is called whenever we modify a field's value:
"""

# ╔═╡ 1cf37484-4da8-11eb-2366-fb81d0a99c1a
Meta.lower(Main, :( fc.path = "/etc/hosts" ))

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
	end
	error("Unsupported property: $s")
end

# ╔═╡ cf02d362-4da9-11eb-2ce5-198fa955a091
fc2 = FileContent("/etc/hosts")

# ╔═╡ 7b212b6c-4daa-11eb-29ac-9318750195b4
fc2.contents

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
# ╠═e45ffcaa-4da7-11eb-0143-f987977eb9d6
# ╠═adbb26c0-4da7-11eb-2cdc-7dbf5639fb0c
# ╟─0cc5a848-4da8-11eb-0140-4fe0b13b1272
# ╠═1cf37484-4da8-11eb-2366-fb81d0a99c1a
# ╠═e703d4a8-4da8-11eb-3a09-4950168a4227
# ╠═a0b23aba-4daa-11eb-1438-edc2e6311cc9
# ╠═cf02d362-4da9-11eb-2ce5-198fa955a091
# ╠═7b212b6c-4daa-11eb-29ac-9318750195b4
# ╠═28b4bed0-4da7-11eb-0cf2-071444e06846
# ╠═eea4351a-4da6-11eb-0c95-f3ba4c21ae14
