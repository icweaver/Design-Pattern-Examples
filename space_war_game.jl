### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 84993928-458f-11eb-0c83-fd8e29c8c59f
using PlutoUI

# ╔═╡ 0c8eb4f0-4592-11eb-2ee7-d94178e464ca
md"""
**Struct set-up**
"""

# ╔═╡ f1785c3a-458b-11eb-1e6b-a70c50cb06ad
mutable struct Position
	x::Int
	y::Int
end

# ╔═╡ 1a17be86-458e-11eb-0427-ed9eed786e36
struct Size
	width::Int
	height::Int
end

# ╔═╡ 259a50f2-458e-11eb-0958-ff4f96a091e9
struct Widget
	name::String
	position::Position
	size::Size
end

# ╔═╡ fd73efd0-4591-11eb-2fac-87fe1d195e5b
md"""
**Custom display**
"""

# ╔═╡ 9293db9c-458e-11eb-22f7-694b57d06e2e
begin
	Base.show(io::IO, p::Position) = print(io, "($(p.x), $(p.y))")
	Base.show(io::IO, s::Size) = print(io, "$(s.width) × $(s.height)")
	function Base.show(io::IO, w::Widget)
		print(io, "$(w.name) at $(w.position), size $(w.size)")
	end
end

# ╔═╡ d541165a-4591-11eb-231d-ddaf71d51fee
md"""
**Basic movements**
"""

# ╔═╡ 34af09ca-458e-11eb-1064-bdd7784791f4
begin
	move_up!(widget::Widget, v::Int) = widget.position.y -= v
	move_down!(widget::Widget, v::Int) = widget.position.y += v
	move_left!(widget::Widget, v::Int) = widget.position.x -= v
	move_right!(widget::Widget, v::Int) = widget.position.x += v
end;

# ╔═╡ 1bdc39cc-4591-11eb-21c3-c72829468c94
w = Widget("asteroid", Position(0, 0), Size(10, 20))

# ╔═╡ 4ab765ca-4591-11eb-2503-e7e612063962
move_up!(w, 10); move_right!(w, 5); w

# ╔═╡ 3a99761e-4592-11eb-3845-f38be449e083
md"""
Now let's create a bunch of asteroids:
"""

# ╔═╡ 468aa9ac-4592-11eb-3997-71cfe7b441d2
function make_asteroids(; N::Int, pos_range=0:200, size_range=10:30)
	pos_rand() = rand(pos_range)
	size_rand() = rand(size_range)
	
	return [
		Widget(
			"Asteriod #$i",
			Position(pos_rand(), pos_rand()),
			Size(size_rand(), size_rand())
		)
		for i in 1:N
	]
end

# ╔═╡ a78eb3f6-4592-11eb-0861-99a40d944385
targets = make_asteroids(N=5)

# ╔═╡ 2e6abe36-4595-11eb-26f6-9f73c83d8166
md"""
And set up a schematic for shooting them:
"""

# ╔═╡ bf043186-4593-11eb-18c7-ef9582f3a4dc
function shoot(from::Widget, targets::Widget...)
	for target in targets
		println("$(from.name) → $(target.name)")
	end
end

# ╔═╡ 31fa7704-4594-11eb-3565-e398e6c0c6e3
spaceship = Widget("Spaceship", Position(0, 0), Size(30, 30))

# ╔═╡ 480a43c6-4594-11eb-22bf-4feafd946768
with_terminal() do
	shoot(spaceship, targets...)
end

# ╔═╡ Cell order:
# ╟─0c8eb4f0-4592-11eb-2ee7-d94178e464ca
# ╠═f1785c3a-458b-11eb-1e6b-a70c50cb06ad
# ╠═1a17be86-458e-11eb-0427-ed9eed786e36
# ╠═259a50f2-458e-11eb-0958-ff4f96a091e9
# ╟─fd73efd0-4591-11eb-2fac-87fe1d195e5b
# ╠═9293db9c-458e-11eb-22f7-694b57d06e2e
# ╟─d541165a-4591-11eb-231d-ddaf71d51fee
# ╠═34af09ca-458e-11eb-1064-bdd7784791f4
# ╠═1bdc39cc-4591-11eb-21c3-c72829468c94
# ╠═4ab765ca-4591-11eb-2503-e7e612063962
# ╟─3a99761e-4592-11eb-3845-f38be449e083
# ╠═468aa9ac-4592-11eb-3997-71cfe7b441d2
# ╠═a78eb3f6-4592-11eb-0861-99a40d944385
# ╟─2e6abe36-4595-11eb-26f6-9f73c83d8166
# ╠═bf043186-4593-11eb-18c7-ef9582f3a4dc
# ╠═31fa7704-4594-11eb-3565-e398e6c0c6e3
# ╠═480a43c6-4594-11eb-22bf-4feafd946768
# ╠═84993928-458f-11eb-0c83-fd8e29c8c59f
