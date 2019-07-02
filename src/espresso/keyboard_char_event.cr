require "./bool_conversion"
require "./keyboard_event"

module Espresso
  # Event triggered when a unicode character is entered.
  struct KeyboardCharEvent < KeyboardEvent
    # The character that was entered.
    getter char : Char

    # Creates the keyboard event.
    protected def initialize(pointer, codepoint)
      super(pointer)
      @char = codepoint.unsafe_chr
    end
  end
end
