require "./window_event"

module Espresso
  # Event involving the mouse.
  abstract struct MouseEvent < WindowEvent
    # Mouse tied to the window that was involved in the event.
    def mouse : Mouse
      window.mouse
    end
  end
end
