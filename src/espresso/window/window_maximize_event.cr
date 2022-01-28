require "./window_event"

module Espresso
  # Event that is triggered when a window is maximized or restored from that state.
  # Restored does not mean the window is in a non-maximized windowed state.
  # A window could be restored to a full screen or iconified state.
  struct WindowMaximizeEvent < WindowEvent
    # Indicates whether the window is currently maximized.
    getter? maximized : Bool

    # Creates the event.
    protected def initialize(pointer, value)
      super(pointer)
      @maximized = value.to_bool
    end

    # Indicates whether the window is currently restored (not maximized).
    def restored?
      !@maximized
    end
  end
end
