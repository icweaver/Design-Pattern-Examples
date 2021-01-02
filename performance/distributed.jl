### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ da738f3c-49c5-11eb-11e5-0106cb5c2c82
using PlutoUI

# ╔═╡ bb936ea5-f896-4920-acd5-7e68f28cf0a6
md"""
### Generate data
"""

# ╔═╡ b43b6930-ebf8-41f0-b911-854333743c8f
md"""
Let's start by generating GB worth of test data (but not too large that it can't all fit in memory) to try this on:
"""

# ╔═╡ 22eebfba-49c5-11eb-385b-8bab2a9696d7
function make_data_directories(basename, nfolders)
	for i in 0:(nfolders - 1)
		mkpath(joinpath(basename, string(i)))
	end
end

# ╔═╡ 5964f1ae-49c5-11eb-155e-e30b611bf80e
function locate_file(index, nfolders)
	id = index - 1
	dir = string(id % nfolders)
	return joinpath(dir, "sec$(id).dat")
end

# ╔═╡ 7974f4a8-49c5-11eb-39c1-9940f26ed8eb
function generate_test_data(basename, nfolders, nfiles, nstates, nattr)
	for i in 1:nfiles
		A = rand(nstates, nattr)
		file = locate_file(i, nfolders)
		open(joinpath(basename, file), "w") do io
			write(io, A)
		end
	end
end

# ╔═╡ f664ac60-49c5-11eb-0ef3-8394c6c75996
begin
	const basename = "yee"
	const nfolders = 100
	const nfiles = 20_000
	const nstates = 10_000
	const nattr = 3
	
	# make_data_directories(basename, nfolders)
	# generate_test_data(basename, nfolders, nfiles, nstates, nattr)
end;

# ╔═╡ c2e902e8-1697-414c-ae17-fa7d9125a1f3
md"""
The data is organized as follows:

```julia
distributed_test_data
├── 0
│   ├── sec0.dat
│   ├── sec100.dat
│   ├── ...
│   └── sec19900.dat
├── 1
│   ├── sec1.dat
│   ├── sec101.dat
│   ├── ...
│   └── sec19901.dat
├── ...
│   ├── ...
│   ├── ...
│   ├── ...
│   └── ...
└── 99
    ├── sec99.dat
    ├── sec199.dat
    ├── ...
    └── sec19999.dat
```

In other words, instead of having all $nfiles files stored in a single directory, we have distributed them into $nfolders sub-directories such that the first $nfolders files are stored in directories 0, 1, ..., $(nfolders-1), then the next $nfolders files, and so on.

Each file represents a separate $nstates x $nattr securities matrix ( $nstates futures x $nattr return sources ) stored in binary format. We're now ready to tackle the problem of loading all of this data!
"""

# ╔═╡ e21f0ffc-3ed6-4307-aed1-3975c50f454e
md"""
### Load data into shared array
"""

# ╔═╡ e71b321a-a1b6-41c9-983a-8e721a88a805
md"""
#### Serial example
"""

# ╔═╡ ddab47af-4f28-45f9-9e60-85a318976cc9
md"""
Say we wanted to compute the standard deviation of the returns across all securities. The normal serial way of doing this might look like:

```julia
using Statistics, BenchmarkTools

const nfolders = 100
const nfiles = 20_000
const nstates = 10_000
const nattr = 3

cd("distributed_test_data")

function locate_file(index, nfolders)
    id = index - 1
    dir = string(id % nfolders)
    return joinpath(dir, "sec$(id).dat")
end

function read_val_file!(index, dest, nfolders)
   filename = locate_file(index, nfolders)
   (nstates, nattrs) = size(dest)[1:2]
   open(filename) do io
       nbytes = nstates * nattrs * 8
       buffer = read(io, nbytes)
       A = reinterpret(Float64, buffer)
       dest[:, :, index] = A
   end
end

function load_data!(nfiles, dest, nfolders)
    for i in 1:nfiles
       read_val_file!(i, dest, nfolders)
   end
end

valuation = Array{Float64}(undef, nstates, nattr, nfiles)

# println(Base.summarysize(valuation) / 1024^3)

load_data!(nfiles, valuation, nfolders)

function std_by_security(valuation)
    (nstates, nattr, n) = size(valuation)
    result = zeros(n, nattr)
    for i in 1:n
        for j in 1:nattr
            result[i, j] = std(valuation[:, j, i])
        end
    end
    return result
end

@btime std_by_security($valuation)

println(mean(std_by_security(valuation)))

```

Which gives the following results for our data:

```julia
3.660774 seconds (488.49 k allocations: 4.496 GiB, 0.85% gc time)
933.918 ms (120002 allocations: 4.48 GiB)
0.2886727973019792
```
"""

# ╔═╡ b72b8f3e-955e-4125-ac7f-c49060c879af
md"""
#### Parallel example
"""

# ╔═╡ 67541e29-503b-437f-95b7-9b4bae484108
md"""
Let's try again using a `SharedArray`

```julia
using Distributed, SharedArrays

@everywhere using Statistics, BenchmarkTools

const nfolders = 100
const nfiles = 20_000
const nstates = 10_000
const nattr = 3

@everywhere cd("distributed_test_data")

@everywhere function locate_file(index, nfolders)
    id = index - 1
    dir = string(id % nfolders)
    return joinpath(dir, "sec$(id).dat")
end

@everywhere function read_val_file!(index, dest, nfolders)
   filename = locate_file(index, nfolders)
   (nstates, nattrs) = size(dest)[1:2]
   open(filename) do io
       nbytes = nstates * nattrs * 8
       buffer = read(io, nbytes)
       A = reinterpret(Float64, buffer)
       dest[:, :, index] = A
   end
end

function load_data!(nfiles, dest, nfolders)
   @sync @distributed for i in 1:nfiles
       read_val_file!(i, dest, nfolders)
   end
end

valuation = SharedArray{Float64}(nstates, nattr, nfiles)

load_data!(nfiles, valuation, nfolders)

function std_by_security(valuation)
    (nstates, nattr, n) = size(valuation)
    result = SharedArray{Float64}(n, nattr)
    @sync @distributed for i in 1:n
        for j in 1:nattr
            result[i, j] = std(valuation[:, j, i])
        end
    end
    return result
end

@btime std_by_security($valuation)

println(mean(std_by_security(valuation)))
```

Which gives the following results on 8 worker processes:

```julia
3.274274 seconds (834.81 k allocations: 43.655 MiB, 1.72% gc time)
761.408 ms (2326 allocations: 105.30 KiB)
0.2886727973019792
```

For comparison with the serial process above:

```julia
3.660774 seconds (488.49 k allocations: 4.496 GiB, 0.85% gc time)
933.918 ms (120002 allocations: 4.48 GiB)
0.2886727973019792
```

not only is this faster in loading and running computations on the data, but it also uses significantly less memory. The gap in performance will only increase as we increase the computational complexity, because then the fraction of the total time devoted to overhead from doing the parallel processing will not be as large.
"""

# ╔═╡ ee52faf0-8891-475f-baaf-d45b2ef7b095
PlutoUI.TableOfContents(depth=4)

# ╔═╡ Cell order:
# ╟─bb936ea5-f896-4920-acd5-7e68f28cf0a6
# ╟─b43b6930-ebf8-41f0-b911-854333743c8f
# ╟─22eebfba-49c5-11eb-385b-8bab2a9696d7
# ╟─5964f1ae-49c5-11eb-155e-e30b611bf80e
# ╟─7974f4a8-49c5-11eb-39c1-9940f26ed8eb
# ╠═f664ac60-49c5-11eb-0ef3-8394c6c75996
# ╟─c2e902e8-1697-414c-ae17-fa7d9125a1f3
# ╟─e21f0ffc-3ed6-4307-aed1-3975c50f454e
# ╟─e71b321a-a1b6-41c9-983a-8e721a88a805
# ╟─ddab47af-4f28-45f9-9e60-85a318976cc9
# ╟─b72b8f3e-955e-4125-ac7f-c49060c879af
# ╟─67541e29-503b-437f-95b7-9b4bae484108
# ╠═ee52faf0-8891-475f-baaf-d45b2ef7b095
# ╠═da738f3c-49c5-11eb-11e5-0106cb5c2c82
