### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

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

# ╔═╡ Cell order:
# ╟─cae9618e-4819-11eb-04e9-4f03581c0f5f
# ╠═0fa987da-480f-11eb-2869-f5256c540628
# ╠═1404efd4-4811-11eb-0bca-57c72a4c4b30
