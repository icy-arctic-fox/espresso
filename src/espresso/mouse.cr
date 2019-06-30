require "glfw"
require "./bool_conversion"
require "./button_state"
require "./coordinates"
require "./error_handling"
require "./event_handling"
require "./mouse_button"

module Espresso
  # Information about the mouse that is associated with a window.
  # Each `Window` has its own mouse instance with properties specific to that window.
  # To retrieve a mouse instance, use `Window#mouse`.
  struct Mouse
    include BoolConversion
    include ErrorHandling
    include EventHandling

    # Creates the mouse instance from a GLFW window pointer.
    protected def initialize(@pointer : LibGLFW::Window)
    end

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
    event button, MouseButtonEvent, set_mouse_button_callback

    # Registers a listener to respond when the mouse moves.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `MouseMoveEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_move_listener` with the proc returned by this method.
    #
    # The block is provided with the position, in screen coordinates,
    # relative to the upper-left corner of the content area of the window.
    event move, MouseMoveEvent, set_cursor_pos_callback

    # Registers a listener to respond when the mouse enters or leaves the window's content area.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `MouseEnterEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_enter_listener` with the proc returned by this method.
    event enter, MouseEnterEvent, set_cursor_enter_callback

    # Registers a listener to respond when the mouse is scrolled.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `MouseScrollEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_scroll_listener` with the proc returned by this method.
    #
    # The scroll callback receives all scrolling input,
    # like that from a mouse wheel or a touchpad scrolling area.
    event scroll, MouseScrollEvent, set_scroll_callback

    # Removes all previously registered listeners for all mouse events.
    protected def remove_all_listeners
      clear_button_listeners
      clear_move_listeners
      clear_enter_listeners
      clear_scroll_listeners
    end

    # Returns the last state reported for the specified mouse button to the window.
    # The returned state is one of the values from `ButtonState`.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns `ButtonState::Pressed` the first time you call it
    # for a mouse button that was pressed,
    # even if that mouse button has already been released.
    def button(button : MouseButton)
      action = expect_truthy { LibGLFW.get_mouse_button(@pointer, button.native) }
      ButtonState.from_value(action.to_i)
    end

    # Determines whether the last state reported for the specified mouse button is pressed.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns true the first time you call it for a mouse button that was pressed,
    # even if that mouse button has already been released.
    def button?(button : MouseButton)
      self.button(button).pressed?
    end

    # Returns the last state reported for the left (primary) mouse button to the window.
    # The returned state is one of the values from `ButtonState`.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns `ButtonState::Pressed` the first time you call it
    # for a mouse button that was pressed,
    # even if that mouse button has already been released.
    def left
      button(MouseButton::Left)
    end

    # Determines whether the last state reported for the left (primary) mouse button is pressed.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns true the first time you call it for a mouse button that was pressed,
    # even if that mouse button has already been released.
    def left?
      left.pressed?
    end

    # Returns the last state reported for the right (secondary) mouse button to the window.
    # The returned state is one of the values from `ButtonState`.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns `ButtonState::Pressed` the first time you call it
    # for a mouse button that was pressed,
    # even if that mouse button has already been released.
    def right
      button(MouseButton::Right)
    end

    # Determines whether the last state reported for the right (secondary) mouse button is pressed.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns true the first time you call it for a mouse button that was pressed,
    # even if that mouse button has already been released.
    def right?
      right.pressed?
    end

    # Returns the last state reported for the middle mouse button to the window.
    # The returned state is one of the values from `ButtonState`.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns `ButtonState::Pressed` the first time you call it
    # for a mouse button that was pressed,
    # even if that mouse button has already been released.
    def middle
      button(MouseButton::Middle)
    end

    # Determines whether the last state reported for the middle mouse button is pressed.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns true the first time you call it for a mouse button that was pressed,
    # even if that mouse button has already been released.
    def middle?
      middle.pressed?
    end

    # Returns the position of the cursor, in screen coordinates,
    # relative to the upper-left corner of the content area of the window.
    #
    # If the cursor is disabled (with `#disable`) then the cursor position is unbounded
    # and limited only by the minimum and maximum values of a double.
    #
    # The coordinate can be converted to their integer equivalents with the floor function.
    # Casting directly to an integer type works for positive coordinates, but fails for negative ones.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def position
      x = uninitialized Float64
      y = uninitialized Float64

      checked { LibGLFW.get_cursor_pos(@pointer, pointerof(x), pointerof(y)) }
      Coordinates.new(x, y)
    end

    # Sets the position, in screen coordinates, of the cursor
    # relative to the upper-left corner of the content area of the window.
    # The window must have input focus.
    # If the window does not have input focus when this method is called, it fails silently.
    #
    # **Do not use this method** to implement things like camera controls.
    # GLFW already provides the `#disable` cursor mode that hides the cursor,
    # transparently re-centers it and provides unconstrained cursor motion.
    #
    # If the cursor mode is `#disabled?` then the cursor position is unconstrained
    # and limited only by the minimum and maximum values of a `Float64`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** This method will only work when the cursor mode is `#disabled?`,
    # otherwise it will do nothing.
    def position=(position : Tuple(Float64, Float64))
      move(*position)
    end

    # Sets the position, in screen coordinates, of the cursor
    # relative to the upper-left corner of the content area of the window.
    # The window must have input focus.
    # If the window does not have input focus when this method is called, it fails silently.
    #
    # **Do not use this method** to implement things like camera controls.
    # GLFW already provides the `#disable` cursor mode that hides the cursor,
    # transparently re-centers it and provides unconstrained cursor motion.
    #
    # If the cursor mode is `#disabled?` then the cursor position is unconstrained
    # and limited only by the minimum and maximum values of a `Float64`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** This method will only work when the cursor mode is `#disabled?`,
    # otherwise it will do nothing.
    def position=(position : NamedTuple(x: Float64, y: Float64))
      move(**position)
    end

    # Sets the position, in screen coordinates, of the cursor
    # relative to the upper-left corner of the content area of the window.
    # The window must have input focus.
    # If the window does not have input focus when this method is called, it fails silently.
    #
    # **Do not use this method** to implement things like camera controls.
    # GLFW already provides the `#disable` cursor mode that hides the cursor,
    # transparently re-centers it and provides unconstrained cursor motion.
    #
    # If the cursor mode is `#disabled?` then the cursor position is unconstrained
    # and limited only by the minimum and maximum values of a `Float64`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** This method will only work when the cursor mode is `#disabled?`,
    # otherwise it will do nothing.
    def position=(position)
      move(position.x, position.y)
    end

    # Sets the position, in screen coordinates, of the cursor
    # relative to the upper-left corner of the content area of the window.
    # The window must have input focus.
    # If the window does not have input focus when this method is called, it fails silently.
    #
    # **Do not use this method** to implement things like camera controls.
    # GLFW already provides the `#disable` cursor mode that hides the cursor,
    # transparently re-centers it and provides unconstrained cursor motion.
    #
    # If the cursor mode is `#disabled?` then the cursor position is unconstrained
    # and limited only by the minimum and maximum values of a `Float64`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** This method will only work when the cursor mode is `#disabled?`,
    # otherwise it will do nothing.
    def move(x, y)
      checked { LibGLFW.set_cursor_pos(@pointer, x, y) }
    end

    def cursor=(cursor)
      raise NotImplementedError.new("Mouse#cursor=")
    end

    # Retrieves the current cursor mode for the mouse.
    # This will be one of the values from `CursorMode`.
    #
    # By default, the cursor mode is `CursorMode::Normal`,
    # meaning the regular arrow cursor (or another cursor set with `#cursor=`)
    # is used and cursor motion is not limited.
    def mode
      value = expect_truthy { LibGLFW.get_input_mode(@pointer, LibGLFW::InputMode::Cursor) }
      CursorMode.value_from(value.to_i)
    end

    # Checks whether the cursor is hidden and locked.
    #
    # See also: `#disable`
    def disabled?
      mode.disabled?
    end

    # Hides and grabs the cursor, providing virtual and unlimited cursor movement.
    # This is useful for implementing for example 3D camera controls.
    #
    # This will hide the cursor and lock it to the window.
    # GLFW will then take care of all the details of cursor re-centering
    # and offset calculation and providing the application with a virtual cursor position.
    # This virtual position is provided normally via `#on_move` and `#position`.
    #
    # If you only wish the cursor to become hidden when it is over a window
    # but still want it to behave normally, use `#hide`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # See also: `#disabled?`
    def disable
      checked { LibGLFW.set_input_mode(@pointer, LibGLFW::InputMode::Cursor, LibGLFW::CursorMode::Disabled) }
    end

    # Checks whether the cursor is invisible when it is over the content area of the window.
    #
    # See also: `#hide`
    def hidden?
      mode.hidden?
    end

    # Makes the cursor invisible when it is over the content area of the window
    # but does not restrict the cursor from leaving.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # See also: `#hidden?`
    def hide
      checked { LibGLFW.set_input_mode(@pointer, LibGLFW::InputMode::Cursor, LibGLFW::CursorMode::Hidden) }
    end

    # Checks whether the cursor is visible and behaving normally.
    #
    # See also: `#show`
    def visible?
      mode.normal?
    end

    # Makes the cursor visible and behave normally.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # See also: `#visible?`
    def show
      checked { LibGLFW.set_input_mode(@pointer, LibGLFW::InputMode::Cursor, LibGLFW::CursorMode::Normal) }
    end

    # Indicates whether stick mouse buttons is enabled.
    # If sticky mouse buttons are enabled,
    # a mouse button press will ensure that `#button` (and variants)
    # returns `ButtonState::Pressed` the next time it is called
    # even if the mouse button had been released before the call.
    # This is useful when you are only interested in whether mouse buttons have been pressed
    # but not when or in which order.
    #
    # See also: `#sticky=`
    def sticky?
      value = expect_truthy { LibGLFW.get_input_mode(@pointer, LibGLFW::InputMode::StickyMouseButtons) }
      int_to_bool(value)
    end

    # Enables or disables sticky mouse buttons.
    # If sticky mouse buttons are enabled,
    # a mouse button press will ensure that `#button` (and variants)
    # returns `ButtonState::Pressed` the next time it is called
    # even if the mouse button had been released before the call.
    # This is useful when you are only interested in whether mouse buttons have been pressed
    # but not when or in which order.
    #
    # Whenever you poll state (via `#button`),
    # you risk missing the state change you are looking for.
    # If a pressed mouse button is released again before you poll its state,
    # you will have missed the button press.
    # The recommended solution for this is to use `#on_button`,
    # but there is also the sticky mouse buttons input mode.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # See also: `#sticky?`
    def sticky=(flag)
      value = bool_to_int(flag)
      checked { LibGLFW.set_input_mode(@pointer, LibGLFW::InputMode::StickyMouseButtons, value) }
    end

    # Retrieves the underlying window pointer.
    def to_unsafe
      @pointer
    end

    # Checks whether raw mouse motion is supported on the current system.
    # This status does not change after GLFW has been initialized
    # so you only need to check this once.
    # If you attempt to enable raw motion on a system that does not support it,
    # a `PlatformError` will be raised.
    #
    # Raw mouse motion is closer to the actual motion of the mouse across a surface.
    # It is not affected by the scaling and acceleration
    # applied to the motion of the desktop cursor.
    # That processing is suitable for a cursor
    # while raw motion is better for controlling for example a 3D camera.
    # Because of this, raw mouse motion is only provided when the cursor is disabled.
    def self.raw_motion_supported?
      value = expect_truthy { LibGLFW.raw_mouse_motion_supported }
      int_to_bool(value)
    end
  end
end
