require "./scale"
require "./window_event"

module Espresso
  # Event triggered when the a window's content scale changes.
  struct WindowScaleEvent < WindowEvent
    # The new x-axis content scale of the window.
    getter x : Float32

    # The new y-axis content scale of the window.
    getter y : Float32

    # Creates the event.
    protected def initialize(pointer, @x, @y)
      super(pointer)
    end

    # The new content scale of the window.
    def scale
      Scale.new(@x, @y)
    end
  end
end
