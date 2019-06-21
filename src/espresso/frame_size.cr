module Espresso
  # Sizes of each edge of a window.
  struct FrameSize
    # Size of the left edge, in screen coordinates.
    getter left : Int32

    # Size of the top edge, in screen coordinates.
    getter top : Int32

    # Size of the right edge, in screen coordinates.
    getter right : Int32

    # Size of the bottom edge, in screen coordinates.
    getter bottom : Int32

    # Creates the size with initial values.
    def initialize(@left, @top, @right, @bottom)
    end

    # Creates a string representation of the frame size.
    def to_s(io)
      io << "(Left: "
      io << @left
      io << ", Top: "
      io << @top
      io << ", Right: "
      io << @right
      io << ", Bottom: "
      io << @bottom
      io << ')'
    end
  end
end
