require "./mouse_event"

module Espresso
  # Event triggered when the mouse is scrolled.
  struct MouseScrollEvent < MouseEvent
    # The scroll offset along the x-axis.
    getter x : Float64

    # The scroll offset along the y-axis.
    getter y : Float64

    # Creates the mouse event.
    protected def initialize(pointer, @x, @y)
      super(pointer)
    end
  end
end
