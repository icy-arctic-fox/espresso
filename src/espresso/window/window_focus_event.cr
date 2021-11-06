require "../bool_conversion"
require "./window_event"

module Espresso
  # Event triggered when the window gains or loses focus.
  struct WindowFocusEvent < WindowEvent
    include BoolConversion

    # Indicates whether the window has gained or lost focus.
    getter? focused : Bool

    # Creates the event.
    protected def initialize(pointer, value)
      super(pointer)
      @focused = int_to_bool(value)
    end
  end
end
