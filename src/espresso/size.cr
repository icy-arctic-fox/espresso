module Espresso
  # Two-dimensional size of an object.
  # Contains a width and height,
  # represented as 32-bit integers.
  struct Size
    # Horizontal size.
    getter width : Int32

    # Vertical size.
    getter height : Int32

    # Creates the size with initial values.
    def initialize(@width, @height)
    end

    # Creates a string representation of the size.
    def to_s(io)
      io << '('
      io << @width
      io << ", "
      io << @height
      io << ')'
    end
  end
end
