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

#load_data!(nfiles, valuation, nfolders)

@time load_data!(nfiles, valuation, nfolders)

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

function stats_by_security(valuation, funcs)
    (nstates, nattr, n) = size(valuation)
    results = SharedArray{Float64}(n, nattr, length(funcs))
    @sync @distributed for i in 1:n
        for j in 1:nattr
            for (k, f) in enumerate(funcs)
                results[i, j, k] = f(valuation[:, j, i])
            end
        end
    end
    return results
end

@everywhere using StatsBase: skewness, kurtosis
funcs = (std, skewness, kurtosis)
@time result = stats_by_security(valuation, funcs)
println(mean(result))
