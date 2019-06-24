require "./bool_conversion"
require "./window_event"

module Espresso
  # Event triggered when a window is iconified (minimized) or restored from that state.
  # Restored does not mean the window is in a non-maximized windowed state.
  # A window could be restored to a full screen or maximized state.
  struct WindowIconifyEvent < WindowEvent
    include BoolConversion

    # Indicates whether the window is currently iconified (minimized).
    # When true, the window was just iconified.
    # When false, the window was just restored from being iconified.
    getter? iconified : Bool

    # Creates the event.
    protected def initialize(pointer, value)
      super(pointer)
      @iconified = int_to_bool(value)
    end

    # Indicates whether the window is currently iconified (minimized).
    # When true, the window was just iconified.
    # When false, the window was just restored from being iconified.
    def minimized?
      @iconified
    end

    # Indicates whether the window is currently restored (not iconified).
    def restored?
      !@iconified
    end
  end
end
