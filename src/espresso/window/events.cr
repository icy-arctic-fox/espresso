require "../events/**"
require "./window_topic"

module Espresso
  struct Window
    include WindowTopic

    # Registers a listener to respond when the window is moved.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowMoveEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_move_listener` with the proc returned by this method.
    #
    # **Wayland:** This callback will never be called,
    # as there is no way for an application to know its global position.
    window_event window_move, move : WindowMoveEvent

    # Registers a listener to respond when the window's size changes.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowResizeEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_resize_listener` with the proc returned by this method.
    window_event window_resize, resize : WindowResizeEvent

    # Registers a listener to respond when the user requests the window to be closed.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowClosingEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_closing_listener` with the proc returned by this method.
    #
    # The `#closing?` flag is set before this callback is called,
    # but you can modify it at any time with `#closing=`.
    #
    # **macOS:** Selecting Quit from the application menu will trigger the close callback for all windows.
    window_event window_closing, closing : WindowClosingEvent

    # Registers a listener to respond when the window's contents need to be redrawn,
    # for example if the window has been exposed after having been covered by another window.
    #
    # On compositing window systems such as Aero, Compiz, Aqua or Wayland,
    # where the window contents are saved off-screen,
    # this callback may be called only very infrequently or never at all.
    #
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowRefreshEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_refresh_listener` with the proc returned by this method.
    window_event window_refresh, refresh : WindowRefreshEvent

    # Registers a listener to respond when the window gains or loses focus.
    #
    # After the focus callback is called for a window that lost input focus,
    # synthetic key and mouse button release events will be generated for all such that had been pressed.
    # For more information, see `glfwSetKeyCallback` and `glfwSetMouseButtonCallback`.
    #
    # The block of code passed to this method will be invoked when the request occurs.
    # A `WindowFocusEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_focus_listener` with the proc returned by this method.
    window_event window_focus, focus : WindowFocusEvent

    # Registers a listener to respond when the window is iconified (minimized) or restored from being iconified.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowIconifyEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_iconify_listener` with the proc returned by this method.
    window_event window_iconify, iconify : WindowIconifyEvent

    # Registers a listener to respond when the window is maximized or restored from being maximized.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowMaximizeEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_maximize_listener` with the proc returned by this method.
    window_event resize_maximize, maximize : WindowMaximizeEvent

    # Registers a listener to respond when the window's framebuffer is resized.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowResizeEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_framebuffer_resize_listener` with the proc returned by this method.
    window_event window_framebuffer_resize, framebuffer_resize : WindowResizeEvent

    # Registers a listener to respond when the window's content scaling changes.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowScaleEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_scale_listener` with the proc returned by this method.
    window_event window_scale, scale : WindowScaleEvent

    # Registers a listener to respond when when one or more dragged files are dropped on the window.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowDropEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_drop_listener` with the proc returned by this method.
    #
    # **Wayland:** File drop is currently unimplemented.
    window_event window_drop, drop : WindowDropEvent

    # Registers a listener to respond when the window is iconified (minimized) or restored from being iconified.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowIconifyEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_iconify_listener` with the proc returned by this method.
    @[AlwaysInline]
    def on_minimize(&block : WindowIconifyEvent ->)
      on_iconify(&block)
    end

    # Removes a previously registered listener that responded to the `#on_minimize` callback.
    # The *proc* argument should be the return value of the `#on_minimize` method.
    @[AlwaysInline]
    def remove_minimize_listener(proc : WindowIconifyEvent ->) : Nil
      remove_iconify_listener(proc)
    end
  end
end
