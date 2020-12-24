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

# ╔═╡ 11428978-45be-11eb-0c6d-116c6d70b429
md"""
Now let's have our spaceship make a random move:
"""

# ╔═╡ 2b0a1fce-45be-11eb-1971-4f12ba33e971
function random_move()
	return rand([move_up!, move_down!, move_left!, move_right!])
end

# ╔═╡ 58149724-45be-11eb-1800-a5aded165e36
function random_leap!(w::Widget, move_func!::Function, distance::Int)
	move_func!(w, distance)
end

# ╔═╡ 301cbdd2-45be-11eb-3fd6-9b0bcde2ab65
let
	spaceship = Widget("Spaceship", Position(0, 0), Size(30, 30))
	random_leap!(spaceship, random_move(), 10)
	spaceship
end

# ╔═╡ 20f07a12-45c1-11eb-1fa4-45e707b17de2
md"""
Now let's give our spaceship some weapons! To make things more interesting, our spaceship will need to have some energy to use it.
"""

# ╔═╡ 31ddb6be-45c1-11eb-3d9c-a57699e5a519
has_energy(spaceship) = rand(Bool)

# ╔═╡ 6c25cbcc-45c1-11eb-2c72-27be66fe5c6f
function fire(f::Function, spaceship::Widget)
	if has_energy(spaceship)
		f(spaceship)
	else
		println("Need energy to fire!")
	end
end

# ╔═╡ 108135bc-45c2-11eb-2b6f-3df4816838c3
with_terminal() do
	spaceship = Widget("Spaceship", Position(0, 0), Size(30, 30))
	fire(s -> println("$(s) launched missle!"), spaceship)
end

# ╔═╡ 1094a886-45c2-11eb-3dd6-6179d7126684
md"""
If we want to pass a more complex firing procedure, we can also make use of the `do-block` syntax:
"""

# ╔═╡ 10abc264-45c2-11eb-3b06-1beb003e3591
with_terminal() do
	spaceship = Widget("Spaceship", Position(0, 0), Size(30, 30))
	fire(spaceship) do s
		move_up!(s, 1)
		println("$(s) launched missle!")
		move_down!(s, 1)
	end
end

# ╔═╡ 10c602dc-45c2-11eb-21f8-f3d0a67fc60e
md"""
**MOAR WEAPONS**
"""

# ╔═╡ 10de0f44-45c2-11eb-21fc-f9a05d152889
@enum Weapon Laser Missle; Weapon

# ╔═╡ 9fd1b206-45c4-11eb-0a9d-11e8950033a9
md"""
**Abstract Types/Multiple Dispatch**
"""

# ╔═╡ 0b4e7066-45c5-11eb-24c5-effc9e1f57b0
md"""
We can now generalize our idea of spaceships and asteroids to an `abstract` type `Thing`:
"""

# ╔═╡ 46a7a4ca-45c5-11eb-2a30-fbc74a3fdd73
abstract type Thing end

# ╔═╡ 47274290-45c5-11eb-117e-d11c4ac0b4ac
md"""
With the following functions that can be applied to all `Thing`s:
"""

# ╔═╡ 473be59a-45c5-11eb-3663-d30dda78f854
begin
	position(t::Thing) = t.position
	size(t::Thing) = t.size
	shape(t::Thing) = :unknown
end;

# ╔═╡ 47542eb6-45c5-11eb-3fdd-a1551f760be1
md"""
Now let's make some things.
"""

# ╔═╡ 9be2438c-45c5-11eb-0d0e-1d474099d5ad
struct Spaceship <: Thing
	position::Position
	size::Size
	weapon::Weapon
end

# ╔═╡ d8e4a6e4-45c5-11eb-2f81-bf83c5d76669
shape(s::Spaceship) = :saucer

# ╔═╡ 9bfaa9b8-45c5-11eb-3e91-bfcf6b41d203
struct Asteroid <: Thing
	position::Position
	size::Size
end

# ╔═╡ 9c0e3b22-45c5-11eb-0be3-45fc928a39ad
let
	s1 = Spaceship(Position(3, 4), Size(20, 20), Laser)
	(position(s1), size(s1), shape(s1))
end

# ╔═╡ 9c255456-45c5-11eb-0a23-af107b8276e1
let
	a1 = Asteroid(Position(0, 10), Size(30, 20))
	(position(a1), size(a1), shape(a1))
end

# ╔═╡ 476dde24-45c5-11eb-0cce-450ebf84ab47
md"""
As seen above, the corresponding method of `shape` is dispatched based on the subtype of each `Thing`. *Multiple* dispatch is when this is done for more than one signature of a given method, so let's do that next!
"""

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
# ╟─11428978-45be-11eb-0c6d-116c6d70b429
# ╠═2b0a1fce-45be-11eb-1971-4f12ba33e971
# ╠═58149724-45be-11eb-1800-a5aded165e36
# ╠═301cbdd2-45be-11eb-3fd6-9b0bcde2ab65
# ╠═20f07a12-45c1-11eb-1fa4-45e707b17de2
# ╠═31ddb6be-45c1-11eb-3d9c-a57699e5a519
# ╠═6c25cbcc-45c1-11eb-2c72-27be66fe5c6f
# ╠═108135bc-45c2-11eb-2b6f-3df4816838c3
# ╟─1094a886-45c2-11eb-3dd6-6179d7126684
# ╠═10abc264-45c2-11eb-3b06-1beb003e3591
# ╟─10c602dc-45c2-11eb-21f8-f3d0a67fc60e
# ╠═10de0f44-45c2-11eb-21fc-f9a05d152889
# ╟─9fd1b206-45c4-11eb-0a9d-11e8950033a9
# ╟─0b4e7066-45c5-11eb-24c5-effc9e1f57b0
# ╠═46a7a4ca-45c5-11eb-2a30-fbc74a3fdd73
# ╟─47274290-45c5-11eb-117e-d11c4ac0b4ac
# ╠═473be59a-45c5-11eb-3663-d30dda78f854
# ╟─47542eb6-45c5-11eb-3fdd-a1551f760be1
# ╠═9be2438c-45c5-11eb-0d0e-1d474099d5ad
# ╠═d8e4a6e4-45c5-11eb-2f81-bf83c5d76669
# ╠═9bfaa9b8-45c5-11eb-3e91-bfcf6b41d203
# ╠═9c0e3b22-45c5-11eb-0be3-45fc928a39ad
# ╠═9c255456-45c5-11eb-0a23-af107b8276e1
# ╟─476dde24-45c5-11eb-0cce-450ebf84ab47
# ╠═84993928-458f-11eb-0c83-fd8e29c8c59f
