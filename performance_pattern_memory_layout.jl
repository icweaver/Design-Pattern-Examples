### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 4fc1a142-49a2-11eb-30e1-8122b01849f1
using StructArrays

# ╔═╡ 009c0c72-499a-11eb-372d-eb6822f21f70
using PlutoUI, CSV, BenchmarkTools, Statistics

# ╔═╡ e7313da2-499e-11eb-2b6b-0936e67fdafe
md"""
Let's say we have the following business app:
"""

# ╔═╡ 03a82e8e-4998-11eb-1c38-29a69676d4e3
struct TripPayment
	vendor_id::Int
	tpep_pickup_datetime::String
	tpep_dropoff_datetime::String
	passenger_count::Int
	trip_distance::Float64
	fare_amount::Float64
	extra::Float64
	mta_tax::Float64
	tip_amount::Float64
	tolls_amount::Float64
	improvement_surcharge::Float64
	total_amount::Float64
end

# ╔═╡ f3689b7e-4999-11eb-3230-354f66766510
function read_trip_payment_file(file)
	f = CSV.File(file, datarow = 2)
	records = Vector{TripPayment}(undef, length(f))
	for (i, row) in enumerate(f)
		records[i] = TripPayment(
			row.VendorID,
			row.tpep_pickup_datetime,
			row.tpep_dropoff_datetime,
			row.passenger_count,
			row.trip_distance,
			row.fare_amount,
			row.extra,
			row.mta_tax,
			row.tip_amount,
			row.tolls_amount,
			row.improvement_surcharge,
			row.total_amount,
		)
	end
	return records
end

# ╔═╡ ff1fa598-499e-11eb-223b-a9210d080bf5
md"""
If we wanted to compute the average cab fare, we could do something like:
"""

# ╔═╡ 3cd0f2ca-499a-11eb-2e54-8b6c95875c74
records = read_trip_payment_file("yellow_tripdata_2018-12_100k.csv");

# ╔═╡ af9dbe8a-499c-11eb-3a8a-35771f983a02
with_terminal() do
	@btime mean(r.fare_amount for r in records)
end

# ╔═╡ 3bb9bc0a-499f-11eb-2f76-d52d391470b9
md"""
This is pretty quick since we are using a generator, but we still have to individually access the `fare_amount` field in  each element of our array of structs. Compare this to just taking the mean of an array of floats:
"""

# ╔═╡ f13a2b74-4999-11eb-3a62-0da061796806
fare_amounts_arr = [r.fare_amount for r in records];

# ╔═╡ f1513d3c-4999-11eb-2c89-272406e22d51
with_terminal() do
	@btime mean($fare_amounts_arr)
end

# ╔═╡ 73bd506c-499f-11eb-10f2-25222acda330
md"""
This is way faster and is allocation free! We are seeing the power of using highly optimized instructions for densely packed arrays in contiguous memory. Contrast this with the much slower operation of first iterating into each entry of our array of structs, and then having to iterate again by an offset in memory determined by the data type of each entry of our struct.

Let's use the power of arrays to re-organize our data and try again:
"""

# ╔═╡ 2e3093c0-49a0-11eb-09ff-d9238b549541
struct TripPaymentColumnarData
	vendor_id::Vector{Int}
	tpep_pickup_datetime::Vector{String}
	tpep_dropoff_datetime::Vector{String}
	passenger_count::Vector{Int}
	trip_distance::Vector{Float64}
	fare_amount::Vector{Float64}
	extra::Vector{Float64}
	mta_tax::Vector{Float64}
	tip_amount::Vector{Float64}
	tolls_amount::Vector{Float64}
	improvement_surcharge::Vector{Float64}
	total_amount::Vector{Float64}
end

# ╔═╡ 4f24aad6-49a2-11eb-3017-b9139d06cddb
columnar_records = TripPaymentColumnarData(
	[r.vendor_id for r in records],
	[r.tpep_pickup_datetime for r in records],
	[r.tpep_dropoff_datetime for r in records],
	[r.passenger_count for r in records],
	[r.trip_distance for r in records],
	[r.fare_amount for r in records],
	[r.extra for r in records],
	[r.mta_tax for r in records],
	[r.tip_amount for r in records],
	[r.tolls_amount for r in records],
	[r.improvement_surcharge for r in records],
	[r.total_amount for r in records],
)

# ╔═╡ 4f941ad8-49a2-11eb-0bf3-1b4d82675d12
with_terminal() do
	@btime mean($columnar_records.fare_amount)
end

# ╔═╡ 4fa87e8a-49a2-11eb-1fa8-fdac3e5dc8ea
md"""
Alright, it's fast again, but wow was that gross to write. "There's gotta be a better way":
"""

# ╔═╡ 2f0076e4-49a3-11eb-060a-c95a72414989
sa = StructArray(records);

# ╔═╡ 6180ddf2-49a3-11eb-33b1-0d913b3f1bd6
with_terminal() do
	@btime mean($sa.fare_amount)
end

# ╔═╡ 8750981a-49a3-11eb-367d-4b29a20e5fd4
md"""
Done.
"""

# ╔═╡ 6dba471c-49a4-11eb-1692-5d898633464b
md"""
It seems that the trade-off though is that `sa` takes up a bit more memory since it needs to make a copy.
"""

# ╔═╡ 8775673a-49a3-11eb-1030-6fa12bcceac8
Base.summarysize(records) / 1024^2

# ╔═╡ 878c639a-49a3-11eb-228e-930b66f401ec
Base.summarysize(sa) / 1024^2

# ╔═╡ Cell order:
# ╟─e7313da2-499e-11eb-2b6b-0936e67fdafe
# ╠═03a82e8e-4998-11eb-1c38-29a69676d4e3
# ╠═f3689b7e-4999-11eb-3230-354f66766510
# ╟─ff1fa598-499e-11eb-223b-a9210d080bf5
# ╠═3cd0f2ca-499a-11eb-2e54-8b6c95875c74
# ╠═af9dbe8a-499c-11eb-3a8a-35771f983a02
# ╟─3bb9bc0a-499f-11eb-2f76-d52d391470b9
# ╠═f13a2b74-4999-11eb-3a62-0da061796806
# ╠═f1513d3c-4999-11eb-2c89-272406e22d51
# ╟─73bd506c-499f-11eb-10f2-25222acda330
# ╠═2e3093c0-49a0-11eb-09ff-d9238b549541
# ╠═4f24aad6-49a2-11eb-3017-b9139d06cddb
# ╠═4f941ad8-49a2-11eb-0bf3-1b4d82675d12
# ╟─4fa87e8a-49a2-11eb-1fa8-fdac3e5dc8ea
# ╠═4fc1a142-49a2-11eb-30e1-8122b01849f1
# ╠═2f0076e4-49a3-11eb-060a-c95a72414989
# ╠═6180ddf2-49a3-11eb-33b1-0d913b3f1bd6
# ╟─8750981a-49a3-11eb-367d-4b29a20e5fd4
# ╟─6dba471c-49a4-11eb-1692-5d898633464b
# ╠═8775673a-49a3-11eb-1030-6fa12bcceac8
# ╠═878c639a-49a3-11eb-228e-930b66f401ec
# ╠═009c0c72-499a-11eb-372d-eb6822f21f70
