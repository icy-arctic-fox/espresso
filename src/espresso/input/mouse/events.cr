require "../../events/**"
require "../../window/window_topic"

module Espresso
  struct Mouse
    include WindowTopic

    # Registers a listener to respond when a mouse button is pressed or released.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `MouseButtonEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_button_listener` with the proc returned by this method.
    #
    # When a window loses input focus,
    # it will generate synthetic mouse button release events for all pressed mouse buttons.
    # You can tell these events from user-generated events
    # by the fact that the synthetic ones are generated after the focus loss event has been processed,
    # i.e. after the `Window#on_focus` event has been triggered.
    window_event mouse_button, button : MouseButtonEvent

    # Registers a listener to respond when the mouse moves.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `MouseMoveEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_move_listener` with the proc returned by this method.
    #
    # The block is provided with the position, in screen coordinates,
    # relative to the upper-left corner of the content area of the window.
    window_event mouse_move, move : MouseMoveEvent

    # Registers a listener to respond when the mouse enters or leaves the window's content area.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `MouseEnterEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_enter_listener` with the proc returned by this method.
    window_event mouse_enter, enter : MouseEnterEvent

    # Registers a listener to respond when the mouse is scrolled.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `MouseScrollEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_scroll_listener` with the proc returned by this method.
    #
    # The scroll callback receives all scrolling input,
    # like that from a mouse wheel or a touchpad scrolling area.
    window_event mouse_scroll, scroll : MouseScrollEvent
  end
end
