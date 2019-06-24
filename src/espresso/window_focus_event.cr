require "./bool_conversion"
require "./window_event"

module Espresso
  struct WindowFocusEvent < WindowEvent
    include BoolConversion

    getter? focused : Bool

    protected def initialize(pointer, value)
      super(pointer)
      @focused = int_to_bool(value)
    end
  end
end
