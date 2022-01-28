module Espresso
  # Two-dimensional position of an object.
  # Contains an x and y-coordinate
  # represented as 32-bit integers.
  struct Position
    # Distance along the x-axis.
    getter x : Int32

    # Distance along the y-axis.
    getter y : Int32

    # Creates the position with initial values.
    def initialize(@x, @y)
    end

    # Creates a string representation of the position.
    def to_s(io)
      io << '(' << @x << ", " << @y << ')'
    end
  end
end
