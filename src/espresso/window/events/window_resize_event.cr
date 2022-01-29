require "../../size"
require "./window_event"

module Espresso
  # Event triggered when a window's size is changed.
  struct WindowResizeEvent < WindowEvent
    # New width of the window.
    getter width : Int32

    # New height of the window.
    getter height : Int32

    # Creates the event.
    protected def initialize(pointer, @width, @height)
      super(pointer)
    end

    # New dimensions of the window.
    def size : Size
      Size.new(@width, @height)
    end
  end
end
