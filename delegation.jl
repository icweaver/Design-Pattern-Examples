### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ db9d15d8-47ff-11eb-0aec-ad57b3650ccf
using Dates

# ╔═╡ 7b7c43ae-4806-11eb-2e8f-2ddfd8f618df
md"""
Let's say we have to extend some enterprise code. It's really old and expensive, and we are not allowed to modify the source code. Or maybe the source code is really long and not very well maintained, and learning how the code works well enough to make the necessary changes just wouldn't be worth the headache. All we have is the API below:
"""

# ╔═╡ 67ad7bae-47ff-11eb-1008-cff31a5e751f
mutable struct Account
	account_number::String
	balance::Float64
	data_opened::Date
end

# ╔═╡ f0a16c72-47ff-11eb-0f99-c752425549aa
# Accessors
begin
account_number(a::Account) = a.account_number
balance(a::Account) = a.balance
date_opened(a::Account) = a.date_opened
end;

# ╔═╡ 2c1c170c-4800-11eb-31f9-11b1fdf2da43
# Functions
begin
	function deposit!(a::Account, amount::Real)
		a.balance += amount
		return a.balance
	end
	function withdraw!(a::Account, amount::Real)
		a.balance -= amount
		return a.balance
	end
	function transfer!(from::Account, to::Account, amount::Real)
		withdraw!(from, amount)
		deposit!(to, amount)
		return amount
	end
end;

# ╔═╡ 1dea8bf8-4807-11eb-0c20-03978cad681b
md"""
We would like to extend this with a savings account feature, because apparently thinking about the future is important. What we can do is essentially copy the API above and add our own `interest_rate` field:
"""

# ╔═╡ 35ea0806-4801-11eb-1171-511c428b244f
struct SavingsAccount
	acct::Account
	interest_rate::Float64

	SavingsAccount(account_number, balance, date_opened, interest_rate) = new(
		Account(account_number, balance, date_opened), interest_rate
	)
end

# ╔═╡ 5b1cb558-4807-11eb-2829-857f9d4602e8
md"""
And wrap the API:
"""

# ╔═╡ 0670f368-4802-11eb-2f78-b7ccbd26ad9c
# Forward accessors
begin
account_number(sa::SavingsAccount) = account_number(sa.acct)
balance(sa::SavingsAccount) = balance(sa.acct)
date_opened(sa::SavingsAccount) = date_opened(sa.acct)
end;

# ╔═╡ 5389af1e-4802-11eb-17f5-ef5234406c33
# Forward methods
begin
	deposit!(sa::SavingsAccount, amount::Real) = deposit!(sa.acct, amount)
	withdraw!(sa::SavingsAccount, amount::Real) = withdraw!(sa.acct, amount)
	transfer!(sa1::SavingsAccount, sa2::SavingsAccount, amount::Real) = transfer!(
		sa1.acct, sa2.acct, amount
	)
end;

# ╔═╡ 7b4eec8a-4807-11eb-2a55-9f9e0511a0ae
md"""
Now that our new savings account feature has all of the same functionality as the original `Account` struct, we can finally extend it:
"""

# ╔═╡ abef70e4-4802-11eb-08df-5d4ed38dd997
# New accessor
interest_rate(sa::SavingsAccount) = sa.interest_rate

# ╔═╡ bf31c512-4802-11eb-06e6-ad333b9f3c0f
# New behavior
function acccrue_daily_interest!(sa::SavingsAccount)
	interest = balance(sa) * interest_rate(sa) / 365.0
	deposit!(sa, interest)
end

# ╔═╡ 66a72292-4803-11eb-0180-a55e57b772d9
my_savings = SavingsAccount("1234", 100.0, today(), 0.01)

# ╔═╡ Cell order:
# ╟─7b7c43ae-4806-11eb-2e8f-2ddfd8f618df
# ╠═67ad7bae-47ff-11eb-1008-cff31a5e751f
# ╠═f0a16c72-47ff-11eb-0f99-c752425549aa
# ╠═2c1c170c-4800-11eb-31f9-11b1fdf2da43
# ╟─1dea8bf8-4807-11eb-0c20-03978cad681b
# ╠═35ea0806-4801-11eb-1171-511c428b244f
# ╟─5b1cb558-4807-11eb-2829-857f9d4602e8
# ╠═0670f368-4802-11eb-2f78-b7ccbd26ad9c
# ╠═5389af1e-4802-11eb-17f5-ef5234406c33
# ╟─7b4eec8a-4807-11eb-2a55-9f9e0511a0ae
# ╠═abef70e4-4802-11eb-08df-5d4ed38dd997
# ╠═bf31c512-4802-11eb-06e6-ad333b9f3c0f
# ╠═66a72292-4803-11eb-0180-a55e57b772d9
# ╠═db9d15d8-47ff-11eb-0aec-ad57b3650ccf
