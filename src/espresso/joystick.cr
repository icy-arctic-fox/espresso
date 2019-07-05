require "glfw"
require "./bool_conversion"
require "./button_state"
require "./error_handling"

module Espresso
  struct Joystick
    include BoolConversion
    include ErrorHandling

    # Creates a reference to a joystick with the specified ID.
    protected def initialize(@id : LibGLFW::Joystick)
    end

    # Returns all possible joysticks, connected and disconnected.
    # GLFW supports a maximum of 16 joysticks,
    # so the collection returned by this method always has 16 elements.
    def self.all
      LibGLFW::Joystick.values.map do |id|
        Joystick.new(id)
      end
    end

    # Iterates through all possible joysticks, connected and disconnected.
    # The joystick is yieled to the block.
    def self.each
      LibGLFW::Joystick.each do |id|
        yield Joystick.new(id)
      end
    end

    # Returns a list of all connected joysticks.
    def self.connected
      all.select(&.connected?)
    end

    # Iterates through all connected joysticks.
    # The joystick is yieled to the block.
    def self.each_connected
      each do |joystick|
        yield joystick if joystick.connected?
      end
    end

    # Checks if the joystick is currently connected (present).
    #
    # There is no need to call this method before other methods in this type,
    # as they all check for presence before performing any other work.
    def connected?
      value = expect_truthy { LibGLFW.joystick_present(@id) }
      int_to_bool(value)
    end

    # Retrieves the values of all axes of this joystick.
    # Each element in the array is a value between -1.0 and 1.0.
    #
    # If this joystick is not present (`#connected?`),
    # this method will return nil, but will not raise an error.
    # This can be used instead of first calling `#connected?`.
    #
    # The returned `Slice` is allocated and freed by GLFW.
    # You should not free it yourself.
    # It is valid until the specified joystick is disconnected or the library is terminated.
    def axes?
      count = uninitialized Int32
      pointer = expect_truthy { LibGLFW.get_joystick_axes(@id, pointerof(count)) }
      pointer ? Slice.new(pointer, count) : nil
    end

    # Retrieves the values of all axes of this joystick.
    # Each element in the array is a value between -1.0 and 1.0.
    #
    # If this joystick is not present (`#connected?`),
    # this method will raise an error.
    #
    # The returned `Slice` is allocated and freed by GLFW.
    # You should not free it yourself.
    # It is valid until the specified joystick is disconnected or the library is terminated.
    def axes
      axes? || raise "Joystick disconnected"
    end

    # Retrieves the state of all buttons of this joystick.
    # Each element in the array is either `ButtonState::Pressed` or `ButtonState::Released`.
    #
    # For backward compatibility with earlier versions of GLFW that did not have `#hats?`,
    # the button array also includes all hats, each represented as four buttons.
    # The hats are in the same order as returned by `#hats?`
    # and are in the order up, right, down and left.
    # To disable these extra buttons,
    # set the *joystick_hat_buttons* hint before initialization (see `Espresso#init`).
    #
    # If this joystick is not present (`#connected?`),
    # this method will return nil, but will not raise an error.
    # This can be used instead of first calling `#connected?`.
    #
    # The returned `Slice` is allocated and freed by GLFW.
    # You should not free it yourself.
    # It is valid until the specified joystick is disconnected or the library is terminated.
    def buttons?
      count = uninitialized Int32
      pointer = expect_truthy { LibGLFW.get_joystick_buttons(@id, pointerof(count)) }
      pointer ? Slice.new(pointer, count).unsafe_as(Slice(ButtonState)) : nil
    end

    # Retrieves the state of all buttons of this joystick.
    # Each element in the array is either `ButtonState::Pressed` or `ButtonState::Released`.
    #
    # For backward compatibility with earlier versions of GLFW that did not have `#hats?`,
    # the button array also includes all hats, each represented as four buttons.
    # The hats are in the same order as returned by `#hats?`
    # and are in the order up, right, down and left.
    # To disable these extra buttons,
    # set the *joystick_hat_buttons* hint before initialization (see `Espresso#init`).
    #
    # If this joystick is not present (`#connected?`),
    # this method will raise an error.
    #
    # The returned `Slice` is allocated and freed by GLFW.
    # You should not free it yourself.
    # It is valid until the specified joystick is disconnected or the library is terminated.
    def buttons
      buttons? || raise "Joystick disconnected"
    end

    # Retrieves the state of all hats of this joystick.
    # Each element in the array is a `JoystickHatState`.
    #
    # The diagonal directions are bitwise combinations of the primary (up, right, down and left) directions.
    #
    # If this joystick is not present (`#connected?`),
    # this method will return nil, but will not raise an error.
    # This can be used instead of first calling `#connected?`.
    #
    # The returned `Slice` is allocated and freed by GLFW.
    # You should not free it yourself.
    # It is valid until the specified joystick is disconnected or the library is terminated.
    def hats?
      count = uninitialized Int32
      pointer = expect_truthy { LibGLFW.get_joystick_hats(@id, pointerof(count)) }
      pointer ? Slice.new(pointer, count).unsafe_as(Slice(JoystickHatState)) : nil
    end

    # Retrieves the state of all hats of this joystick.
    # Each element in the array is a `JoystickHatState`.
    #
    # The diagonal directions are bitwise combinations of the primary (up, right, down and left) directions.
    #
    # If this joystick is not present (`#connected?`),
    # this method will raise an error.
    #
    # The returned `Slice` is allocated and freed by GLFW.
    # You should not free it yourself.
    # It is valid until the specified joystick is disconnected or the library is terminated.
    def hats
      hats? || raise "Joystick disconnected"
    end

    # Retrieves the name, encoded as UTF-8, of this joystick.
    #
    # If this joystick is not present (`#connected?`),
    # this method will return nil, but will not raise an error.
    # This can be used instead of first calling `#connected?`.
    def name?
      chars = expect_truthy { LibGLFW.get_joystick_name(@id) }
      chars ? String.new(chars) : nil
    end

    # Retrieves the name, encoded as UTF-8, of this joystick.
    #
    # If this joystick is not present (`#connected?`),
    # this method will raise an error.
    def name
      name? || raise "Joystick disconnected"
    end

    # Retrieves the SDL compatible GUID, as a UTF-8 encoded hexadecimal string, of this joystick.
    #
    # The GUID is what connects a joystick to a gamepad mapping.
    # A connected joystick will always have a GUID even if there is no gamepad mapping assigned to it.
    #
    # If this joystick is not present (`#connected?`),
    # this method will return nil, but will not raise an error.
    # This can be used instead of first calling `#connected?`.
    #
    # The GUID uses the format introduced in SDL 2.0.5.
    # This GUID tries to uniquely identify the make and model of a joystick
    # but does not identify a specific unit,
    # e.g. all wired Xbox 360 controllers will have the same GUID on that platform.
    # The GUID for a unit may vary between platforms
    # depending on what hardware information the platform specific APIs provide.
    def guid?
      chars = expect_truthy { LibGLFW.get_joystick_guid(@id) }
      chars ? String.new(chars) : nil
    end

    # Retrieves the SDL compatible GUID, as a UTF-8 encoded hexadecimal string, of this joystick.
    #
    # The GUID is what connects a joystick to a gamepad mapping.
    # A connected joystick will always have a GUID even if there is no gamepad mapping assigned to it.
    #
    # If this joystick is not present (`#connected?`),
    # this method will raise an error.
    #
    # The GUID uses the format introduced in SDL 2.0.5.
    # This GUID tries to uniquely identify the make and model of a joystick
    # but does not identify a specific unit,
    # e.g. all wired Xbox 360 controllers will have the same GUID on that platform.
    # The GUID for a unit may vary between platforms
    # depending on what hardware information the platform specific APIs provide.
    def guid
      guid? || raise "Joystick disconnected"
    end

    # Retrieves the current value of the user-defined pointer of this joystick.
    # The initial value is nil.
    #
    # This function may be called from the `#on_disconnect` callback.
    def user_pointer
      checked { LibGLFW.get_joystick_user_pointer(@id) }
    end

    # Sets the user-defined pointer of this joystick.
    # The current value is retained until the joystick is disconnected.
    # The initial value is nil.
    #
    # This function may be called from the `#on_disconnect` callback.
    def user_pointer=(pointer)
      checked { LibGLFW.set_joystick_user_pointer(@id, pointer) }
    end

    # Checks whether this joystick is both present and has a gamepad mapping.
    #
    # If the specified joystick is present (`#connected?`)
    # but does not have a gamepad mapping this method will return false
    # but will not raise an error.
    # Call `#connected?` to check if a joystick is present regardless of whether it has a mapping.
    def gamepad?
      value = expect_truthy { LibGLFW.joystick_is_gamepad(@id) }
      int_to_bool(value)
    end
  end
end
