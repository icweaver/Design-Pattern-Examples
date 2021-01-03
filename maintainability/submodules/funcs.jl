# funcs.jl - Common calculation functions

export interest, rate, mortgage

interest(amount, rate) = amount * (1 + rate)

rate(amount, interest) = interest / amount

# Uses payment function from Mortgage.jl
function mortgage(home_price, down_payment, rate, years)
    return payment(home_price - down_payment, rate, years)
end
