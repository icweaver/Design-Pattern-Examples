### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

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
generate_test_data(folder, 100_000)

# ╔═╡ da738f3c-49c5-11eb-11e5-0106cb5c2c82


# ╔═╡ Cell order:
# ╠═22eebfba-49c5-11eb-385b-8bab2a9696d7
# ╠═5964f1ae-49c5-11eb-155e-e30b611bf80e
# ╠═7974f4a8-49c5-11eb-39c1-9940f26ed8eb
# ╠═f664ac60-49c5-11eb-0ef3-8394c6c75996
# ╠═19ff41dc-49c6-11eb-08af-738af740cea3
# ╠═da613760-49c5-11eb-202a-71a317bf8850
# ╠═da738f3c-49c5-11eb-11e5-0106cb5c2c82
