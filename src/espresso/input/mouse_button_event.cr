require "./button_state"
require "./modifier_key"
require "./mouse_button"
require "./mouse_event"

module Espresso
  # Event triggered when a mouse button is pressed or released.
  struct MouseButtonEvent < MouseEvent
    # Button that was pressed or released.
    getter button : MouseButton

    # New state of the mouse button.
    getter state : ButtonState

    # Modifier keys held down when the event occurred.
    getter modifiers : ModifierKey

    # Creates the mouse event.
    protected def initialize(pointer, button, action, mods)
      super(pointer)
      @button = MouseButton.new(button.to_i)
      @state = ButtonState.new(action.to_i)
      @modifiers = ModifierKey.new(mods.to_i)
    end

    # Indicates whether the left (primary) mouse button was involved.
    def left?
      @button.left?
    end

    # Indicates whether the right (secondary) mouse button was involved.
    def right?
      @button.right?
    end

    # Indicates whether the middle mouse button was involved.
    def middle?
      @button.middle?
    end

    # Indicates whether the button was pressed.
    def pressed?
      @state.pressed?
    end

    # Indicates whether the button was released.
    def released?
      @state.released?
    end
  end
end
