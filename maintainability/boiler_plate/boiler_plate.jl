### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 175cd174-4d84-11eb-1c2e-a73bcc87975d
using Dates

# ╔═╡ 9ccc99e2-4d80-11eb-1975-19d1c5826a95
using Revise, PlutoUI, CodeTracking

# ╔═╡ e0c2d058-4d80-11eb-3261-d1781a74c56d
md"""
In this notebook we will go over three different ways of writing boilerplate code. In these examples, we will be writing a simple file logger with the following requirements:

* info-level logger accepts messages with info, warning, or error levels
* warning-level logger accepts messages with warning or error leveles only
* error-level logger accpets messages with an error level only

This logger will have three logging levels:
"""

# ╔═╡ 741d8604-4d81-11eb-04d1-2db9bf505782
begin
	
const INFO=1
const WARNING=2
const ERROR=3
	
end;

# ╔═╡ cfffe866-4d83-11eb-3dc8-d7d19fd61939
md"""
which can be used to easily determine when a message has a logging level as high as what the logger can accept. An implementation might start with a struct like:
"""

# ╔═╡ d87dd3c2-4d81-11eb-3e8e-77219ca7eee0
begin
	
struct Logger
	filename # log file name
	level # minimum level acceptable to be logged
	handle # file handle
end
Logger(filename, level) = Logger(filename, level, open(filename, "w"))

end;

# ╔═╡ 6f55225c-4d82-11eb-25da-010624db50db
md"""
The constructor for it can then automatically open a file for writing. Now let's take a look at what a logging function for info-level messages might looks like:
"""

# ╔═╡ 1a8d0882-4d84-11eb-090d-21ab9eb263b1
function info!(logger::Logger, args...)
	if logger.level <= INFO
		let io = logger.handle
			print(io, trunc(now(), Dates.Second), " [INFO] ")
			for (idx, arg) in enumerate(args)
				idx > 0 && print(io, " ")
				print(io, arg)
			end
			println(io)
			flush(io)
		end
	end
end

# ╔═╡ b36b4bde-4d84-11eb-2bc2-fd041b7ed3cc
let
	info_logger = Logger("/tmp/info.log", INFO)
	info!(info_logger, "hello", 1234)
	info!(info_logger, "hello", 5678, 910)
	readlines("/tmp/info.log")
end

# ╔═╡ 4a6b2898-4d86-11eb-0974-77b4885e321f
md"""
At this point, we may want to manually write the rest of the boilerplate for a similar `warning!` and `error!` logging function. And this is where we take a deep breath and resist that urge. Here comes the first boilerplate writing option.
"""

# ╔═╡ b3012eb2-4d80-11eb-0a03-07e054980f4a
md"""
# 1. Code generation
"""

# ╔═╡ bda7dbda-4d86-11eb-2230-c52f30027715
for level in (:info, :warning, :error)
	lower_level_str = String(level)
	upper_level_str = uppercase(lower_level_str)
	upper_level_sym = Symbol(upper_level_str)
	
	fn = Symbol("$(lower_level_str)!")
	label = " [ $upper_level_str ] "
	
	@eval function $fn(logger::Logger, args...)
		if logger.level <= $upper_level_sym
			let io = logger.handle
				print(io, trunc(now(), Dates.Second), $label)
				for (idx, arg) in enumerate(args)
					idx > 0 && print(io, " ")
					print(io, arg)
				end
				println(io)
				flush(io)
			end
		end
	end	
end

# ╔═╡ 5dbaed34-4d8b-11eb-30c4-19b4a6e77c23
md"""
Now the other logging functions should be defined:
"""

# ╔═╡ 844cf4be-4d87-11eb-2257-0bdf5c206005
let
	info_logger = Logger("/tmp/info.log", INFO)
	info!(info_logger, "hello", 1234)
	warning!(info_logger, "hello", 5678)
	error!(info_logger, "hello", "0000")
	readlines("/tmp/info.log")
end

# ╔═╡ 6f258c1e-4d8b-11eb-1030-238317268e34
md"""
This works, but the functions were made in the background and can only be inspected with external packages like `CodeTracking` and `MacroTools`. 99% of the time though, macros are overkill and there is probably a better way to tackle the problem if we consider re-organizing/generalizing our thought process a little. Let's do that next for the second example of writing boilerplate code.
"""

# ╔═╡ 98936288-4d8b-11eb-258b-ad4b58f114ed
md"""
# 2. Generalized function 
"""

# ╔═╡ 3f824adc-4d8c-11eb-34d1-dd0b5ab60044
md"""
What if we just took a step back and wrote a generalized version of our `info!` function like this:
"""

# ╔═╡ ad8acb86-4d8b-11eb-021b-db6b8ad4645b
function logme!(level, label, logger::Logger, args...)
	if logger.level <= level
		let io = logger.handle
			print(io, trunc(now(), Dates.Second), " [ $label ] ")
			for (idx, arg) in enumerate(args)
				idx > 0 && print(io, " ")
				print(io, arg)
			end
			println(io)
			flush(io)
		end	
	end
end

# ╔═╡ eedda388-4d8b-11eb-0712-5f0a1827194d
md"""
This is just like the `info!` specific function, excpet the level and label have been abstracted away into the arguments of the generalized function above. Now we can explicity write the logger specific functions without needing to re-copying the main logic multiple times:
"""

# ╔═╡ 999bdf74-4d8c-11eb-3749-b9418e15bc5d
begin
	info2!(logger::Logger, msg...) = logme!(INFO, "INFO", logger, msg...)
	warning2!(logger::Logger, msg...) = logme!(WARNING, "WARNING", logger, msg...)
	error2!(logger::Logger, msg...) = logme!(ERROR, "ERROR", logger, msg...)
end;

# ╔═╡ 6ba1441e-4d8d-11eb-1637-5be961a77793
begin
	info_logger = Logger("/tmp/info.log", INFO)
	info2!(info_logger, "hello", 1234)
	warning2!(info_logger, "hello", 5678)
	error2!(info_logger, "hello", "0000")
	readlines("/tmp/info.log")
end

# ╔═╡ ba8296a0-4d8d-11eb-0b94-15f8a3827034
md"""
Finally, we can reduce the amount of code written a bit more in our third and final example.
"""

# ╔═╡ cac74e2a-4d8d-11eb-08f3-d98a6ab0e22a
md"""
# 3. Closures
"""

# ╔═╡ cdb437e2-4d8d-11eb-0014-a546f4e954bd
function make_log_func(level, label)
	(logger::Logger, args...) -> begin
		if logger.level <= level
			let io = logger.handle
				print(io, trunc(now(), Dates.Second), " [ $label ] ")
				for (idx, arg) in enumerate(args)
					idx > 0 && print(io, " ")
					print(io, arg)
				end
				println(io)
				flush(io)
			end	
		end
	end
end

# ╔═╡ 465ff870-4d8e-11eb-2b8b-85e133c1781c
begin
	info3! = make_log_func(INFO, "INFO")
	warning3! = make_log_func(WARNING, "WARNING")
	error3! = make_log_func(ERROR, "ERROR")
end;

# ╔═╡ bcdcf5a2-4d8e-11eb-0e76-6b8db47026a4
let
	info_logger = Logger("/tmp/info.log", INFO)
	info3!(info_logger, "hello", 1234)
	warning3!(info_logger, "hello", 5678)
	error3!(info_logger, "hello", "0000")
	readlines("/tmp/info.log")
end

# ╔═╡ ae6bdbac-4d80-11eb-045b-517ae5c9db8a
PlutoUI.TableOfContents()

# ╔═╡ Cell order:
# ╟─e0c2d058-4d80-11eb-3261-d1781a74c56d
# ╠═741d8604-4d81-11eb-04d1-2db9bf505782
# ╟─cfffe866-4d83-11eb-3dc8-d7d19fd61939
# ╠═d87dd3c2-4d81-11eb-3e8e-77219ca7eee0
# ╟─6f55225c-4d82-11eb-25da-010624db50db
# ╠═175cd174-4d84-11eb-1c2e-a73bcc87975d
# ╠═1a8d0882-4d84-11eb-090d-21ab9eb263b1
# ╠═b36b4bde-4d84-11eb-2bc2-fd041b7ed3cc
# ╟─4a6b2898-4d86-11eb-0974-77b4885e321f
# ╟─b3012eb2-4d80-11eb-0a03-07e054980f4a
# ╠═bda7dbda-4d86-11eb-2230-c52f30027715
# ╟─5dbaed34-4d8b-11eb-30c4-19b4a6e77c23
# ╠═844cf4be-4d87-11eb-2257-0bdf5c206005
# ╟─6f258c1e-4d8b-11eb-1030-238317268e34
# ╟─98936288-4d8b-11eb-258b-ad4b58f114ed
# ╟─3f824adc-4d8c-11eb-34d1-dd0b5ab60044
# ╠═ad8acb86-4d8b-11eb-021b-db6b8ad4645b
# ╟─eedda388-4d8b-11eb-0712-5f0a1827194d
# ╠═999bdf74-4d8c-11eb-3749-b9418e15bc5d
# ╠═6ba1441e-4d8d-11eb-1637-5be961a77793
# ╟─ba8296a0-4d8d-11eb-0b94-15f8a3827034
# ╟─cac74e2a-4d8d-11eb-08f3-d98a6ab0e22a
# ╠═cdb437e2-4d8d-11eb-0014-a546f4e954bd
# ╠═465ff870-4d8e-11eb-2b8b-85e133c1781c
# ╠═bcdcf5a2-4d8e-11eb-0e76-6b8db47026a4
# ╠═ae6bdbac-4d80-11eb-045b-517ae5c9db8a
# ╠═9ccc99e2-4d80-11eb-1975-19d1c5826a95
