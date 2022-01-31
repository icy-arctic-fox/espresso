require "./mouse_event"

module Espresso
  # Event triggered when the mouse moves.
  struct MouseMoveEvent < MouseEvent
    # The new cursor x-coordinate, relative to the left edge of the content area.
    getter x : Float64

    # The new cursor y-coordinate, relative to the top edge of the content area.
    getter y : Float64

    # Creates the mouse event.
    protected def initialize(pointer, @x, @y)
      super(pointer)
    end

    # The new cursor position, relative to the top-left corner of the content area.
    def position : Coordinates
      Coordinates.new(@x, @y)
    end

    # The new cursor position, relative to the top-left corner of the content area.
    @[AlwaysInline]
    def coordinates : Coordinates
      position
    end
  end
end
