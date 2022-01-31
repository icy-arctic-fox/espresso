require "../../events/**"
require "../../window/window_topic"

module Espresso
  struct Keyboard
    include WindowTopic

    # Registers a listener to respond when a key is pressed, released, or repeated.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `KeyboardKeyEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_key_listener` with the proc returned by this method.
    #
    # This event deals with physical keys,
    # with layout independent key tokens named after their values
    # in the standard US keyboard layout.
    # If you want to input text, use `#on_char` instead.
    #
    # When a window loses input focus,
    # it will generate synthetic key release events for all pressed keys.
    # You can tell these events from user-generated events
    # by the fact that the synthetic ones are generated after the focus loss event has been processed,
    # i.e. after the `Window#on_focus` listeners has been called.
    window_event keyboard_key, key : KeyboardKeyEvent

    # Registers a listener to respond when a character is entered.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `KeyboardCharEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_char_listener` with the proc returned by this method.
    #
    # The character callback is intended for Unicode text input.
    # As it deals with characters, it is keyboard layout dependent,
    # whereas the `#on_key` event is not.
    # Characters do not map 1:1 to physical keys,
    # as a key may produce zero, one or more characters.
    # If you want to know whether a specific physical key was pressed or released,
    # see the `#on_key` event instead.
    #
    # The character callback behaves as system text input normally does
    # and will not be called if modifier keys are held down
    # that would prevent normal text input on that platform,
    # for example a Super (Command) key on macOS or Alt key on Windows.
    window_event keyboard_char, char : KeyboardCharEvent

    # Registers a listener to respond when a character is entered.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `KeyboardCharEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_char_listener` with the proc returned by this method.
    #
    # This event is intended for implementing custom Unicode character input.
    # For regular Unicode text input, use `#on_char` instead.
    # Like `#on_char`, this event deals with characters and is keyboard layout dependent.
    # Characters do not map 1:1 to physical keys, as a key may produce zero, one or more characters.
    # If you want to know whether a specific physical key was pressed or released, use `#on_key` instead.
    #
    # **Deprecated:** Scheduled for removal in GLFW 4.0.
    window_event keyboard_char_mods, char_mods : KeyboardCharModsEvent
  end
end
