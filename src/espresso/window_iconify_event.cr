require "./bool_conversion"
require "./window_event"

module Espresso
  struct WindowIconifyEvent < WindowEvent
    include BoolConversion

    getter? iconified : Bool

    protected def initialize(pointer, value)
      super(pointer)
      @iconified = int_to_bool(value)
    end

    def minimized?
      @iconified
    end

    def restored?
      !@iconified
    end
  end
end
