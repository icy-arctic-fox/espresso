require "./window_event"

module Espresso
  # Event triggered when the user indicates they want to close the window.
  # This event does not mean the window is closed or that it should be.
  # To cancel the close attempt, call `#cancel`.
  struct WindowClosingEvent < WindowEvent
    # Cancels the close attempt.
    # Marks the window as not closing.
    def cancel
      @window.closing = false
    end
  end
end
