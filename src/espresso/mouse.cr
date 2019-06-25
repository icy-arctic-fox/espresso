require "glfw"
require "./bool_conversion"
require "./button_state"
require "./coordinates"
require "./error_handling"
require "./mouse_button"

module Espresso
  # Information about the mouse that is associated with a window.
  # Each `Window` has its own mouse instance with properties specific to that window.
  # To retrieve a mouse instance, use `Window#mouse`.
  struct Mouse
    include BoolConversion
    include ErrorHandling

    # Creates the mouse instance from a GLFW window pointer.
    protected def initialize(@pointer : LibGLFW::Window)
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
