require "../window/window_event"

module Espresso
  # Event involving the mouse.
  abstract struct MouseEvent < WindowEvent
    # Mouse tied to the window that was involved in the event.
    def mouse
      window.mouse
    end
  end
end
