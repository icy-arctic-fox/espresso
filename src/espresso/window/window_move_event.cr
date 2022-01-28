require "../position"
require "./window_event"

module Espresso
  # Event triggered when the window is moved.
  struct WindowMoveEvent < WindowEvent
    # The new x-coordinate, in screen coordinates, of the upper-left corner
    # of the content area of the window.
    getter x : Int32

    # The new y-coordinate, in screen coordinates, of the upper-left corner
    # of the content area of the window.
    getter y : Int32

    # Creates the event.
    protected def initialize(pointer, @x, @y)
      super(pointer)
    end

    # The new coordinates of the upper-left corner of the content area of the window.
    def position : Position
      Position.new(@x, @y)
    end
  end
end
