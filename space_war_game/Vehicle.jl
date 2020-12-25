"""
This module has the following parts:
1. Export/Imports
2. Interface documentation
3. Generic definitions for the interface
4. Game logic
"""
module Vehicle
    # 1. Exports/Imports
    export go!

    # 2. Interface documentation
    """
    A vehicle (v) must implement the following functions:

    power_on!(v) - turn on the vehicle's engined
    power_off!(v) - turn off the vehicle's engine
    turn!(v, direction) - steer the vehicle to the specified direction
    move!(v, distance) - move the vehicle by the specified distance
    position(v) - returns the (x, y) position of the vehicle
    """

    # 3. Generic definitions for the interface
    function power_on! end
    function power_off! end
    function turn! end
    function move! end
    function position end

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
        nothing
    end
end # module
