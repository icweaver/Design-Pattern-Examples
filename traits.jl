### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 86066edc-481b-11eb-1b91-fd0d04bcc2ec
using AbstractTrees, PlutoUI

# ╔═╡ 48174c04-481b-11eb-0e35-8dcf35d00792
md"""
**From before:**
"""

# ╔═╡ ebe80846-481b-11eb-3fc8-1dd81ca1de27
AbstractTrees.children(x::Type) = subtypes(x)

# ╔═╡ 0fa987da-480f-11eb-2869-f5256c540628
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

# ╔═╡ 1404efd4-4811-11eb-0bca-57c72a4c4b30
begin
	struct Residence <: House
		location
	end
	
	struct Stock <: Equity
		symbol
		name
	end
	
	struct TreasuryBill <: FixedIncome
		cusip
	end
	
	struct Money <: Cash
		curreny
		amount
	end
end

# ╔═╡ 7c280d78-481b-11eb-2bd9-e3cb7c964493
with_terminal() do
	print_tree(Asset)
end

# ╔═╡ cae9618e-4819-11eb-04e9-4f03581c0f5f
md"""
**The problem**: Say we want to be able to trade assets. We can only trade liquid investments, so how would we handle each case? We could try an `if statement`:
```julia
const LiquidInvestments = Union{Investment, Cash}

if asset isa LiquidInvestments
	initiate_trade()
else
	throw_warning()
end
```

but there are a few problems with this:

* We would have to update the `Union` every time we want to add a new tradeable asset.
* If this part of the code was closed to the user, they wouldn't be able to extend it easily anyway.
* This if-then-else logic could be sprinkled in a bunch of different places throughout the code, and we would have to update all of them every time we want to make a change.

**The solution:** holy traits
"""

# ╔═╡ db6918b0-4821-11eb-01e4-812befda091a
md"""
We start by defining the trait itself. In this case, we can organize it with an `IsLiquid` and `IsIlliquid` type that are both subtypes of the `LiquidityStyle` trait:

```julia
abstract type LiquidityStyle end
struct IsLiquid <: LiquidityStyle end
struct IsIlliquid <: LiquidityStyle end
```
"""

# ╔═╡ ca0079b6-4825-11eb-030a-edd7abdd6298
md"""
Next, we assign data types to these traits to categorize our Assets by liquidity:
"""

# ╔═╡ 9decfe52-4826-11eb-2e1f-0d61bb1f9114
md"""
With this trait set-up, we can now implement it on some test data:
"""

# ╔═╡ 83bb3c48-4820-11eb-1982-e9f75c1a59af
assets = Asset[
	Money("USD", 100.00),
	Stock("FZROX", 500),
	TreasuryBill(12345689),
	Residence("1234 Maple St."),
]

# ╔═╡ 75bd23b6-4827-11eb-2d8e-cdd2315bc5d8
md"""
We can play the same game with a `marketprice` function that also varies based on liquidity:
"""

# ╔═╡ f392627e-4827-11eb-2189-5d15a08d2804
md"""
We just put in some stubs above, so let's actually start implementing them now:
"""

# ╔═╡ 07f65c66-4828-11eb-25e9-bbf55238c8c6
begin 
	marketprice(x::Money) = x.amount
	marketprice(x::Stock) = rand(200:250) # Could connect to a stock lookup service
end

# ╔═╡ 287f9f0e-4828-11eb-0a82-6bebf14d6382
md"""
A powerful result from using holy traits is that it works for other type hierarchies too!
"""

# ╔═╡ 83816a58-4828-11eb-2fba-fd6355569463
begin
	abstract type Literature end
	
	struct Book <: Literature
		name
	end
end

# ╔═╡ 52a69dea-481c-11eb-264f-6b0c91a44536
begin
	abstract type LiquidityStyle end
	struct IsLiquid <: LiquidityStyle end
	struct IsIlliquid <: LiquidityStyle end
	
	# Illiquid by default
	LiquidityStyle(::Type) = IsIlliquid()
	
	# Cash always liquid
	LiquidityStyle(::Type{<:Cash}) = IsLiquid()
	
	# Any subtype of Investments is liquid
	LiquidityStyle(::Type{<:Investment}) = IsLiquid()
	
	# Assign trait
	LiquidityStyle(::Type{Book}) = IsLiquid()
end	

# ╔═╡ ca0d6ffc-481d-11eb-059d-6f0db2da8056
begin
	tradable(x::T) where {T} = tradable(LiquidityStyle(T), x)
	tradable(::IsLiquid, x) = true
	tradable(::IsIlliquid, x) = false
end

# ╔═╡ 56107474-4821-11eb-00d8-6f8bbdb43f47
tradable.(assets)

# ╔═╡ d53b8112-4826-11eb-2ae9-957461770608
begin
	marketprice(x::T) where {T} = marketprice(LiquidityStyle(T), x)
	function marketprice(::IsLiquid, x)
		println("Please implement pricing function for $(typeof(x))")
	end
	function marketprice(::IsIlliquid, x)
		println("Price for illiquid asset $x is not available")
	end
end

# ╔═╡ 93cfb9ee-4828-11eb-2ab5-a9a92b56c052
marketprice(b::Book) = 10.0

# ╔═╡ 4b4c686c-4827-11eb-3b78-bfcb1cfed3fb
with_terminal() do
	marketprice.(assets)
end

# ╔═╡ e205a0ce-4828-11eb-1d6e-713b19eb6bac
md"""
We can now trade books just like any other asset.
"""

# ╔═╡ Cell order:
# ╟─48174c04-481b-11eb-0e35-8dcf35d00792
# ╠═86066edc-481b-11eb-1b91-fd0d04bcc2ec
# ╠═ebe80846-481b-11eb-3fc8-1dd81ca1de27
# ╠═0fa987da-480f-11eb-2869-f5256c540628
# ╠═1404efd4-4811-11eb-0bca-57c72a4c4b30
# ╠═7c280d78-481b-11eb-2bd9-e3cb7c964493
# ╟─cae9618e-4819-11eb-04e9-4f03581c0f5f
# ╟─db6918b0-4821-11eb-01e4-812befda091a
# ╟─ca0079b6-4825-11eb-030a-edd7abdd6298
# ╠═52a69dea-481c-11eb-264f-6b0c91a44536
# ╟─9decfe52-4826-11eb-2e1f-0d61bb1f9114
# ╠═ca0d6ffc-481d-11eb-059d-6f0db2da8056
# ╠═83bb3c48-4820-11eb-1982-e9f75c1a59af
# ╠═56107474-4821-11eb-00d8-6f8bbdb43f47
# ╟─75bd23b6-4827-11eb-2d8e-cdd2315bc5d8
# ╠═d53b8112-4826-11eb-2ae9-957461770608
# ╠═4b4c686c-4827-11eb-3b78-bfcb1cfed3fb
# ╟─f392627e-4827-11eb-2189-5d15a08d2804
# ╠═07f65c66-4828-11eb-25e9-bbf55238c8c6
# ╟─287f9f0e-4828-11eb-0a82-6bebf14d6382
# ╠═83816a58-4828-11eb-2fba-fd6355569463
# ╠═93cfb9ee-4828-11eb-2ab5-a9a92b56c052
# ╟─e205a0ce-4828-11eb-1d6e-713b19eb6bac
