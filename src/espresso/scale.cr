module Espresso
  # Scaling of an object in two-dimensions.
  # Contains an x and y scaling amount
  # represented as 32-bit floating-point numbers.
  #
  # A value of 1 means no scaling, or original size.
  # A value of 2, twice the size (bigger),
  # and 0.5, half the size (smaller).
  struct Scale
    # Horizontal scaling amount.
    getter x : Float32

    # Vertical scaling amount.
    getter y : Float32

    # Creates the scale with initial values.
    def initialize(@x, @y)
    end

    # Creates a string representation of the scale.
    def to_s(io)
      io << '(' << @x << "x, " << @y << "x)"
    end
  end
end
