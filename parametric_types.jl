### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 8463e984-44a0-11eb-38b8-a14d14406fa6
using PlutoUI, AbstractTrees

# ╔═╡ 57415b5e-449f-11eb-0316-3f136b90bab7
begin
	abstract type Asset end
	
	abstract type Cash <: Asset end	
	abstract type Investment <: Asset end
	abstract type Property <: Asset end
	
	abstract type Equity <: Investment end
	abstract type FixedIncome <: Investment end
	
	abstract type House <: Property end
	abstract type Apartment <: Property end
end

# ╔═╡ 12e923f6-44ea-11eb-1edf-dd389b8efa71
with_terminal() do
	print_tree(Asset)
end

# ╔═╡ 0e8cdc4e-44ea-11eb-078c-65f03fbd60d6
AbstractTrees.children(x::Type) = subtypes(x)

# ╔═╡ 25ea045e-449f-11eb-1592-cb152256d99c
struct Stock <: Equity
	symbol::String
	name::String
end

# ╔═╡ 19c0f5c2-44eb-11eb-31f7-2d0e0a30b5a1
struct StockHolding{T <: Real}
	stock::Stock
	quantity::T
end

# ╔═╡ 42ac3df2-44eb-11eb-0e55-9b995438439c
struct StockHolding2{T <: Real, P <: AbstractFloat}
	stock::Stock
	quantity::T
	price::P
	marketvalue::P
end

# ╔═╡ fae59b52-44eb-11eb-055e-77a330a68871
stock = Stock("AAPL", "Apple, Inc.")

# ╔═╡ 1784954c-44ec-11eb-3182-57bb92d6b836
abstract type Holding{P} end

# ╔═╡ 7bf8f2a2-44ec-11eb-17fb-a1fd903d7465
struct StockHolding3{T, P} <: Holding{P}
	stock::Stock
	quantity::T
	price::P
	marketvalue::P	
end

# ╔═╡ ab6479d0-44ec-11eb-0e2e-71e792a0e3cb
# Just another example
struct CashHolding{P} <: Holding{P}
	curreny::String
	amount::P
	marketvalue::P
end

# ╔═╡ c67650c2-44ec-11eb-3f54-5b9731d45988
certificate_in_the_safe = StockHolding3(
	stock,
	100,
	100.00,
	18_000.00,
)

# ╔═╡ e24b5abc-44ed-11eb-1489-d34a7424ebbc
certificate_in_the_safe isa Holding

# ╔═╡ Cell order:
# ╠═57415b5e-449f-11eb-0316-3f136b90bab7
# ╠═12e923f6-44ea-11eb-1edf-dd389b8efa71
# ╠═0e8cdc4e-44ea-11eb-078c-65f03fbd60d6
# ╠═25ea045e-449f-11eb-1592-cb152256d99c
# ╠═19c0f5c2-44eb-11eb-31f7-2d0e0a30b5a1
# ╠═42ac3df2-44eb-11eb-0e55-9b995438439c
# ╠═fae59b52-44eb-11eb-055e-77a330a68871
# ╠═1784954c-44ec-11eb-3182-57bb92d6b836
# ╠═7bf8f2a2-44ec-11eb-17fb-a1fd903d7465
# ╠═ab6479d0-44ec-11eb-0e2e-71e792a0e3cb
# ╠═c67650c2-44ec-11eb-3f54-5b9731d45988
# ╠═e24b5abc-44ed-11eb-1489-d34a7424ebbc
# ╠═8463e984-44a0-11eb-38b8-a14d14406fa6
