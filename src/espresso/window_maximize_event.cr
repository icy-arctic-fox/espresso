require "./bool_conversion"
require "./window_event"

module Espresso
  struct WindowMaximizeEvent < WindowEvent
    include BoolConversion

    getter? maximized : Bool

    protected def initialize(pointer, value)
      super(pointer)
      @maximized = int_to_bool(value)
    end

    def restored?
      !@maximized
    end
  end
end
