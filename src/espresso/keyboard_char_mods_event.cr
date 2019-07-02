require "./bool_conversion"
require "./keyboard_event"

module Espresso
  # Event triggered when a unicode character is entered.
  # This includes modifier keys held when the character was input.
  struct KeyboardCharModsEvent < KeyboardEvent
    # The character that was entered.
    getter char : Char

    # Any modifier keys that were held down when the event occurred.
    getter mods : ModifierKey

    # Creates the keyboard event.
    protected def initialize(pointer, codepoint, mods)
      super(pointer)
      @char = codepoint.unsafe_chr
      @mods = ModifierKey.from_value(mods.to_i)
    end
  end
end
