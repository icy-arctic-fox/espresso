require "./window_event"

module Espresso
  # Event triggered when the window gains or loses focus.
  struct WindowFocusEvent < WindowEvent
    # Indicates whether the window has gained or lost focus.
    getter? focused : Bool

    # Creates the event.
    protected def initialize(pointer, value)
      super(pointer)
      @focused = value.to_bool
    end
  end
end
