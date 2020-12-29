### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 3d576c0e-4889-11eb-002c-2d08d3009934
using Dates

# ╔═╡ 96ae1e48-4888-11eb-14df-a73e20dba2f1
md"""
We're making a trading app to buy and sell stocks. Our first version might look something like this:
"""

# ╔═╡ f5f0aa84-4887-11eb-0727-53c4f008ac38
begin
	abstract type Asset end
	
	abstract type Investment <: Asset end
	
	abstract type Equity <: Investment end
end

# ╔═╡ 35d55bc2-4888-11eb-354d-b5bd7eac6638
abstract type Trade end

# ╔═╡ 407254c2-4888-11eb-16f6-ddb03242636a
@enum LongShort Long Short # Buy or sell

# ╔═╡ 25c36b34-4888-11eb-02a9-017bc58e03ad
struct Stock <: Equity
	symbol::String
	name::String
end

# ╔═╡ 37ee1da8-488e-11eb-304d-47e13b0ecf43
md"""
With the following trading type:

```julia
struct StockTrade <: Trade
	kind::LongShort
	stock::Stock
	quantity::Int
	price::Float64
end		
```
"""

# ╔═╡ e85a9302-4888-11eb-2254-3b224dfec3bc
md"""
Now suppose that we want to support stock options in our next version. We might do something like this:
"""

# ╔═╡ 1ae9c6ee-4889-11eb-2f91-830995fce93f
@enum CallPut Call Put

# ╔═╡ 225fb28a-4889-11eb-1bf4-458f59b3b1cf
struct StockOption <: Equity
	symbol::String
	kind::CallPut
	strike::Float64
	expiration::Date
end

# ╔═╡ 30c1a4f2-488e-11eb-2d49-8350177864db
md"""
With the following trading type:

```julia
struct StockOptionTrade <: Trade
	kind::LongShort
	option::StockOption
	quantity::Int
	price::Float64
end
```
"""

# ╔═╡ ad877ea6-4889-11eb-3caf-5f4f858ec79b
md"""
Already, we are starting to see a lot of code repitition. What if we wanted to add more types in later versions that do similar things? This would just get worse when we start definining functions that do the same exact thing, but for each type:
```julia
sign(t::StockTrade) = t.kind == Long ? 1: -1
payment(t::StockTrade) = sign(t) * t.quantity * t.price

sign(t::StockOptionTrade) = t.kind == Long ? 1 : -1
payment(t::StockOptionTrade) = sign(t) * t.quantity * t.price

...
```
"""

# ╔═╡ 8138dbfa-488a-11eb-185d-7529b94e7719
md"""
Let's generalize our `<Something>Trade` types with **parametric types:**
"""

# ╔═╡ 900810ce-488a-11eb-04d1-f9ad0f9f0658
# Note: We chose Investment because it is the most general supertype of Equity
struct SingleTrade{T <: Investment} <: Trade
	kind::LongShort
	instrument::T
	quantity::Int
	price::Float64
end

# ╔═╡ 4ddb94b8-488b-11eb-1479-cf22da907f57
md"""
And try it out:
"""

# ╔═╡ 68b5607a-488b-11eb-2622-932cc4c9d614
stock = Stock("APPL", "Apple Inc")

# ╔═╡ 7c85919c-488b-11eb-00fe-a766ca29fdaf
option = StockOption("APPLC", Call, 200, today())

# ╔═╡ 690a4900-488b-11eb-3e19-23fe6ae0cf4e
stock_trade = SingleTrade(Long, stock, 100, 188.0)

# ╔═╡ 69215f78-488b-11eb-2d40-a344a211bd4c
option_trade = SingleTrade(Long, option, 1, 3.5)

# ╔═╡ 693540e4-488b-11eb-0388-1d101b9dc58e
md"""
Great, let's make generic versions of the `sign` and `payment` functions for it now:
"""

# ╔═╡ de22f454-488a-11eb-1c5d-513e91283d53
sign(t::SingleTrade{T}) where {T} = t.kind == Long ? 1 : -1

# ╔═╡ e1df5a72-488c-11eb-127b-274554afdfe1
payment(t::SingleTrade{T}) where {T} = sign(t) * t.quantity * t.price

# ╔═╡ 16511cd2-488d-11eb-38b4-ff94d37950f1
md"""
And test them out:
"""

# ╔═╡ 9ae0329e-488d-11eb-0d0d-77a031914c19
md"""
Oh, but what if option contracts actually represent 100 shares of the underlying stock? Easy, we just make a more specific method for it:
"""

# ╔═╡ c72213ae-488d-11eb-12b5-9faf140eeb43
function payment(t::SingleTrade{StockOption})
	return sign(t) * t.quantity * 100 * t.price
end

# ╔═╡ c7c3d3f6-488d-11eb-2019-25875f194253
md"""
What if we want to support pair trading in the next version of this trading software? No worries:
"""

# ╔═╡ c7d87e14-488d-11eb-3d57-89b780d79aa8
struct PairTrade{T <: Investment, S <: Investment} <: Trade
	leg1::SingleTrade{T}
	leg2::SingleTrade{S}
end

# ╔═╡ 13df79cc-4891-11eb-255d-7b1fefc01951
payment(t::PairTrade) = payment(t.leg1) + payment(t.leg2)

# ╔═╡ 1668bfcc-488d-11eb-1a7c-83be7253b851
payment(stock_trade)

# ╔═╡ 16813624-488d-11eb-0aa9-4dec38e71adf
payment(option_trade)

# ╔═╡ 43565978-4891-11eb-0a43-47b46625e623
md"""
And try it out on our stock/option from before:
"""

# ╔═╡ 2f17265e-4891-11eb-2c02-d7e92a7c0354
stock, option

# ╔═╡ 51e8b792-4891-11eb-2033-8f59d70caad5
pt = PairTrade(
	SingleTrade(Long, stock, 100, 188.0),
	SingleTrade(Short, option, 1, 3.5)
)

# ╔═╡ 7f8047ce-4891-11eb-161c-43da35fe42f7
md"""
We are buying 100 shares of the stock and selling 1 option contract, so the paymanet should be ``\$1880 - \$350 = \$18450``.
"""

# ╔═╡ 79f4377a-4891-11eb-201a-bfd90c495596
payment(pt)

# ╔═╡ 752b1398-4892-11eb-1bb8-8d9b5ddfb344
md"""
Nice. Without parametric types, we would have had to define four different payment methods:

```julia
payment(PairTradeWithStockAndStock)
payment(PairTradeWithStockAndStockOption)
payment(PairTradeWithStockOptionAndStock)
payment(PairTradeWithStockOptionAndStockOption)

```
"""

# ╔═╡ c6ff085a-488d-11eb-1ff6-0d02086b21f8
note(text) = Markdown.MD(Markdown.Admonition("note", "Note", [text]))

# ╔═╡ 14519594-4890-11eb-16ab-cb74267b8448
note(
	md"""
	We chose `Investment` because it is the most general supertype of `Equity` that is appropriate for trading."""
)

# ╔═╡ Cell order:
# ╟─96ae1e48-4888-11eb-14df-a73e20dba2f1
# ╠═f5f0aa84-4887-11eb-0727-53c4f008ac38
# ╠═35d55bc2-4888-11eb-354d-b5bd7eac6638
# ╠═407254c2-4888-11eb-16f6-ddb03242636a
# ╠═25c36b34-4888-11eb-02a9-017bc58e03ad
# ╟─37ee1da8-488e-11eb-304d-47e13b0ecf43
# ╟─e85a9302-4888-11eb-2254-3b224dfec3bc
# ╠═3d576c0e-4889-11eb-002c-2d08d3009934
# ╠═1ae9c6ee-4889-11eb-2f91-830995fce93f
# ╠═225fb28a-4889-11eb-1bf4-458f59b3b1cf
# ╟─30c1a4f2-488e-11eb-2d49-8350177864db
# ╟─ad877ea6-4889-11eb-3caf-5f4f858ec79b
# ╟─8138dbfa-488a-11eb-185d-7529b94e7719
# ╟─14519594-4890-11eb-16ab-cb74267b8448
# ╠═900810ce-488a-11eb-04d1-f9ad0f9f0658
# ╟─4ddb94b8-488b-11eb-1479-cf22da907f57
# ╠═68b5607a-488b-11eb-2622-932cc4c9d614
# ╠═7c85919c-488b-11eb-00fe-a766ca29fdaf
# ╠═690a4900-488b-11eb-3e19-23fe6ae0cf4e
# ╠═69215f78-488b-11eb-2d40-a344a211bd4c
# ╟─693540e4-488b-11eb-0388-1d101b9dc58e
# ╠═de22f454-488a-11eb-1c5d-513e91283d53
# ╠═e1df5a72-488c-11eb-127b-274554afdfe1
# ╟─16511cd2-488d-11eb-38b4-ff94d37950f1
# ╠═1668bfcc-488d-11eb-1a7c-83be7253b851
# ╠═16813624-488d-11eb-0aa9-4dec38e71adf
# ╟─9ae0329e-488d-11eb-0d0d-77a031914c19
# ╠═c72213ae-488d-11eb-12b5-9faf140eeb43
# ╟─c7c3d3f6-488d-11eb-2019-25875f194253
# ╠═c7d87e14-488d-11eb-3d57-89b780d79aa8
# ╠═13df79cc-4891-11eb-255d-7b1fefc01951
# ╟─43565978-4891-11eb-0a43-47b46625e623
# ╠═2f17265e-4891-11eb-2c02-d7e92a7c0354
# ╠═51e8b792-4891-11eb-2033-8f59d70caad5
# ╟─7f8047ce-4891-11eb-161c-43da35fe42f7
# ╠═79f4377a-4891-11eb-201a-bfd90c495596
# ╟─752b1398-4892-11eb-1bb8-8d9b5ddfb344
# ╟─c6ff085a-488d-11eb-1ff6-0d02086b21f8
