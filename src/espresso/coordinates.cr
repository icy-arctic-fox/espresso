module Espresso
  # Two-dimensional position of an object.
  # Contains an x and y-coordinate
  # represented as 64-bit floating-pointer numbers.
  struct Coordinates
    # Distance along the x-axis.
    getter x : Float64

    # Distance along the y-axis.
    getter y : Float64

    # Creates the position with initial values.
    def initialize(@x, @y)
    end

    # Creates a string representation of the position.
    def to_s(io)
      io << '(' << @x << ", " << @y << ')'
    end
  end
end
