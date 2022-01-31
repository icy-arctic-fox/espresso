require "./mouse_event"

module Espresso
  # Event triggered when the mouse enters or leaves the content area of its window.
  struct MouseEnterEvent < MouseEvent
    # Indicates whether the mouse entered the window's content area.
    getter? entered : Bool

    # Creates the mouse event.
    protected def initialize(pointer, entered)
      super(pointer)
      @entered = int_to_bool(entered)
    end

    # Indicates whether the mouse left the window's content area.
    def left?
      !@entered
    end
  end
end
