"""
This module has the following parts:
1. Export/Imports
2. Interface documentation
3. Generic definitions for the interface
4. Game logic
"""
module Vehicle
    ####################
    # 1. Exports/Imports
    ####################
    export go!

    ############################
    # 2. Interface documentation
    ############################
    """
    A vehicle (v) must implement the following functions:

    power_on!(v) - turn on the vehicle's engined
    power_off!(v) - turn off the vehicle's engine
    turn!(v, direction) - steer the vehicle to the specified direction
    move!(v, distance) - move the vehicle by the specified distance
    position(v) - returns the (x, y) position of the vehicle

    Optional functions:

    engage_wheels!(v) - engage wheels for landing
    has_wheels(v) - returns true if the vehicle has wheels
    """

    ##########################################
    # 3. Generic definitions for the interface
    ##########################################
    # Hard contracts
    function power_on! end
    function power_off! end
    function turn! end
    function move! end
    function position end

    # Soft contracts
    engage_wheels!(args...) = nothing

    # Traits
    has_wheels(vehicle) = error("Not implemented.")

    # 4. Game logic
    """
    Returns a travel plan from the current position to destination
    """
    function travel_path(position, destination)
        return round(π/6.0, digits=2), 1000 # just a test
    end

    """
    Space travel logic
    """
    function go!(vehicle, destination)
        power_on!(vehicle)
        direction, distance = travel_path(position(vehicle), destination)
        turn!(vehicle, direction)
        move!(vehicle, distance)
        power_off!(vehicle)
        land!(vehicle)
        nothing
    end

    """
    Landing logic
    """
    function land!(vehicle)
        has_wheels(vehicle) && engage_wheels!(vehicle)
        println("Landing vehicle: $vehicle")
    end
end # module
