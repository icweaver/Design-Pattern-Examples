### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 6758d4e4-4808-11eb-14d0-7b234c7c4ace
using Lazy: @forward

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
The naive way of copying the API would be to manually write methods for `SavingsAccount` that just pass the data to the already defined methods:
"""

# ╔═╡ 37fc99bc-4809-11eb-3ffd-c566cfa5b0e3
md"""
```julia
# Forward accessors
account_number(sa::SavingsAccount) = account_number(sa.acct)
balance(sa::SavingsAccount) = balance(sa.acct)
date_opened(sa::SavingsAccount) = date_opened(sa.acct)

# Forward methods
deposit!(sa::SavingsAccount, amount::Real) = deposit!(sa.acct, amount)
withdraw!(sa::SavingsAccount, amount::Real) = withdraw!(sa.acct, amount)
transfer!(sa1::SavingsAccount, sa2::SavingsAccount, amount::Real) = transfer!(
	sa1.acct, sa2.acct, amount
)

```

That is already 6 lines of redundant boilerplate code, just to add one extra feature. What if this API had hundreds of methods! This is where macros come in to save the day. `Lazy.jl` has a `@forward` macro to do all of the passing for us:
"""

# ╔═╡ 9e5ac9a8-4808-11eb-2585-c38326f1c986
# Forward accessors
@forward SavingsAccount.acct account_number, balance, date_opened

# ╔═╡ eb321dd2-4808-11eb-3723-fd78a5a23b41
# Forward methods
@forward SavingsAccount.acct deposit!, withdraw!

# ╔═╡ 33ca5892-480a-11eb-11ba-8fd554950df5
md"""
The only caveat is that this macro only takes two arguments, the field to be passed and a Tuple of functions it is passed to. For this reason, we cannot add `transfer!` to the list, but hey, 5/6 ain't bad! So let's just add that one in manually.
"""

# ╔═╡ 967bd43e-480a-11eb-3002-7d34125cafd6
transfer!(sa1::SavingsAccount, sa2::SavingsAccount, amount::Real) = transfer!(
    sa1.acct, sa2.acct, amount
)

# ╔═╡ 9e0672cc-480a-11eb-3736-93505d8bdc47
sa = SavingsAccount("123", 100.0, today(), 0.01)

# ╔═╡ b9346040-480a-11eb-327a-35c5eb338663
deposit!(sa, 100); sa

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

# ╔═╡ 09bf1400-480c-11eb-1263-bfa17e192a45
md"""
As a final note, there are cases where we wouldn't want to copy the entire API, but just a few key methods. For example, if we wanted to add a Certificate of Deposit feature, we wouldn't want to forward its `acct` field to `withdraw!`. Since we are able to pick and choose what methods are included in the forwarding, delegation is usually preferred over the more OOP concept of inheritance, which automatically forwards to ALL of its methods.
"""

# ╔═╡ Cell order:
# ╟─7b7c43ae-4806-11eb-2e8f-2ddfd8f618df
# ╠═67ad7bae-47ff-11eb-1008-cff31a5e751f
# ╠═f0a16c72-47ff-11eb-0f99-c752425549aa
# ╠═2c1c170c-4800-11eb-31f9-11b1fdf2da43
# ╟─1dea8bf8-4807-11eb-0c20-03978cad681b
# ╠═35ea0806-4801-11eb-1171-511c428b244f
# ╟─5b1cb558-4807-11eb-2829-857f9d4602e8
# ╟─37fc99bc-4809-11eb-3ffd-c566cfa5b0e3
# ╠═6758d4e4-4808-11eb-14d0-7b234c7c4ace
# ╠═9e5ac9a8-4808-11eb-2585-c38326f1c986
# ╠═eb321dd2-4808-11eb-3723-fd78a5a23b41
# ╟─33ca5892-480a-11eb-11ba-8fd554950df5
# ╠═967bd43e-480a-11eb-3002-7d34125cafd6
# ╠═9e0672cc-480a-11eb-3736-93505d8bdc47
# ╠═b9346040-480a-11eb-327a-35c5eb338663
# ╟─7b4eec8a-4807-11eb-2a55-9f9e0511a0ae
# ╠═abef70e4-4802-11eb-08df-5d4ed38dd997
# ╠═bf31c512-4802-11eb-06e6-ad333b9f3c0f
# ╟─09bf1400-480c-11eb-1263-bfa17e192a45
# ╠═db9d15d8-47ff-11eb-0aec-ad57b3650ccf
