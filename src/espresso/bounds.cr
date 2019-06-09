module Espresso
  # Stores the two-dimensional boundaries of an object.
  # This is a rectangular area that the object encompasses.
  struct Bounds
    # X-coordinate of the upper-left corner.
    getter x : Int32

    # Y-coordinate of the upper-left corner.
    getter y : Int32

    # Width of the rectangle.
    getter width : Int32

    # Height of the rectangle.
    getter height : Int32

    # Creates the bounds with initial values.
    def initialize(@x, @y, @width, @height)
    end

    # X-coordinate of the left side.
    def left
      @x
    end

    # X-coordinate of the right side.
    def right
      @x + @width
    end

    # Y-coordinate of the upper bound.
    def top
      @y
    end

    # Y-coordinate of the lower bound.
    def bottom
      @y + @height
    end
  end
end
