module JetsonJets

export JetsonJet

"A moderatley fast vehicle suitable for the whole family"
mutable struct JetsonJet
    "power status: true=one, false=of"
    power::Bool

    "current direction in radians"
    direction::Float64

    "current position coordinate (x, y)"
    position::Tuple{Float64, Float64}

    "whether the ship has wheels or not"
    has_wheels::Bool
end

# Import generic functions
import Vehicle: power_on!, power_off!, turn!, move!, position, engage_wheels!, has_wheels

# Implementation of Vehicle interface
function power_on!(jj::JetsonJet)
    jj.power = true
    println("Powered on: $jj")
    nothing
end

function power_off!(jj::JetsonJet)
    jj.power = false
    println("Powered off: $jj")
    nothing
end

function turn!(jj::JetsonJet, direction)
    jj.direction = direction
    println("Changed direction to $direction: $jj")
    nothing
end

function move!(jj::JetsonJet, distance)
    x, y = jj.position
    dx = round(distance*cos(jj.direction), digits=2)
    dy = round(distance*sin(jj.direction), digits=2)
    jj.position = (x+dx, y+dy)
    println("Changed direction to: $(jj.direction): $jj")
    nothing
end

function position(jj::JetsonJet)
    jj.position
end

function engage_wheels!(jj::JetsonJet)
    println("Deploying landing gear: $jj")
end

function has_wheels(jj::JetsonJet)
    jj.has_wheels
end

end # module
