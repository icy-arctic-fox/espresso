module Espresso
  # Base for all events that are associated with a window.
  abstract struct WindowEvent
    # Window that the event occurred on.
    getter window : Window

    # Creates the event with a GLFW window pointer.
    protected def initialize(pointer)
      @window = Window.new(pointer)
    end
  end
end
