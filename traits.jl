### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

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
# ╠═0fa987da-480f-11eb-2869-f5256c540628
# ╠═1404efd4-4811-11eb-0bca-57c72a4c4b30
