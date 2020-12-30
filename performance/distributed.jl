### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ da738f3c-49c5-11eb-11e5-0106cb5c2c82
using PlutoUI, Distributed, SharedArrays

# ╔═╡ bb936ea5-f896-4920-acd5-7e68f28cf0a6
md"""
### Generate data
"""

# ╔═╡ 22eebfba-49c5-11eb-385b-8bab2a9696d7
function make_data_directories(folder)
	for i in 0:99
		mkpath(joinpath(folder, string(i)))
	end
end

# ╔═╡ 5964f1ae-49c5-11eb-155e-e30b611bf80e
function locate_file(index)
	id = index - 1
	dir = string(id % 100)
	return joinpath(dir, "sec$(id).dat")
end

# ╔═╡ 7974f4a8-49c5-11eb-39c1-9940f26ed8eb
function generate_test_data(folder, nfiles)
	for i in 1:nfiles
		A = rand(10_000, 3)
		file = locate_file(i)
		open(joinpath(folder, file), "w") do io
			write(io, A)
		end
	end
end

# ╔═╡ f664ac60-49c5-11eb-0ef3-8394c6c75996
folder = "distributed_test_data"

# ╔═╡ 19ff41dc-49c6-11eb-08af-738af740cea3
make_data_directories(folder)

# ╔═╡ da613760-49c5-11eb-202a-71a317bf8850
# generate_test_data(folder, 100_000)

# ╔═╡ e21f0ffc-3ed6-4307-aed1-3975c50f454e
md"""
### Load data into shared array
"""

# ╔═╡ 4116099b-0a0c-49b5-909f-7fd1c313c63e
@everywhere function read_val_file!(index, dest)
   filename = locate_file(index)
   (nstates, nattrs) = size(dest)[1:2]
   open(filename) do io
	   nbytes = nstates * nattrs * 8
	   buffer = read(io, nbytes)
	   A = reinterpret(Float64, buffer)
	   dest[:, :, index] = A
   end
end

# ╔═╡ a6e5b0db-a715-435a-96e5-0e428292585c
function load_data!(nfiles, dest)
   @sync @distributed for i in 1:nfiles
	   read_val_file!(i, dest)
   end
end

# ╔═╡ 2658c413-cc53-408d-9c19-4219cd1f54f9
@everywhere function locate_file2(index)
   id = index - 1
   dir = string(id % 100)
   return joinpath(dir, "sec$(id).dat")
end

# ╔═╡ 9064cc15-0467-4977-a341-68e8f3e26e81


# ╔═╡ ee52faf0-8891-475f-baaf-d45b2ef7b095
PlutoUI.TableOfContents()

# ╔═╡ Cell order:
# ╟─bb936ea5-f896-4920-acd5-7e68f28cf0a6
# ╟─22eebfba-49c5-11eb-385b-8bab2a9696d7
# ╠═5964f1ae-49c5-11eb-155e-e30b611bf80e
# ╟─7974f4a8-49c5-11eb-39c1-9940f26ed8eb
# ╠═f664ac60-49c5-11eb-0ef3-8394c6c75996
# ╠═19ff41dc-49c6-11eb-08af-738af740cea3
# ╠═da613760-49c5-11eb-202a-71a317bf8850
# ╠═e21f0ffc-3ed6-4307-aed1-3975c50f454e
# ╠═a6e5b0db-a715-435a-96e5-0e428292585c
# ╠═4116099b-0a0c-49b5-909f-7fd1c313c63e
# ╠═2658c413-cc53-408d-9c19-4219cd1f54f9
# ╠═9064cc15-0467-4977-a341-68e8f3e26e81
# ╠═ee52faf0-8891-475f-baaf-d45b2ef7b095
# ╠═da738f3c-49c5-11eb-11e5-0106cb5c2c82
