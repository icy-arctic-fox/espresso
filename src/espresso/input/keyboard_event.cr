require "../window/window_event"

module Espresso
  # Event involving the keyboard.
  abstract struct KeyboardEvent < WindowEvent
    # Keyboard tied to the window that was involved in the event.
    def keyboard : Keyboard
      window.keyboard
    end
  end
end
