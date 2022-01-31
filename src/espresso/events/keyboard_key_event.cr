require "./keyboard_event"

module Espresso
  # Event triggered when a physical keyboard key is pressed or released.
  struct KeyboardKeyEvent < KeyboardEvent
    # Keyboard key that is pressed or released.
    getter key : Key

    # The scancode of a key is specific to that platform
    # or sometimes even to that machine.
    # Scancodes are intended to allow users to bind keys
    # that don't have a GLFW `Key` token.
    # Such keys have `#key` set to `Key::Unknown`,
    # their state is not saved
    # and so it cannot be queried with `Keyboard#key`.
    #
    # Sometimes GLFW needs to generate synthetic key events,
    # in which case the scancode may be zero.
    getter scancode : Int32

    # State of the key.
    getter state : KeyState

    # Any modifier keys that were held down when the event occurred.
    getter mods : ModifierKey

    # Creates the keyboard event.
    protected def initialize(pointer, key, @scancode, action, mods)
      super(pointer)
      @key = Key.new(key.to_i)
      @state = KeyState.new(action.to_i)
      @mods = ModifierKey.new(mods.to_i)
    end

    # Retrieves the name of the key, encoded as UTF-8.
    # If the key is printable, a string will be returned, nil otherwise.
    def key_name?
      Keyboard.key_name?(@key, @scancode)
    end

    # Indicates whether the key was pressed.
    def pressed?
      state.pressed?
    end

    # Indicates whether the key was released.
    def released?
      state.released?
    end
  end
end
