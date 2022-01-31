require "../error_handling"
require "./joystick/**"

module Espresso
  # Exposes connected joysticks and controllers, with both referred to as joysticks.
  # GLFW supports up to sixteen joysticks.
  # You can test whether a joystick is present/connected with `#connected?`.
  # To access joysticks, use one of: `#all`, `#each`, `#connected`, or `#each_connected`.
  #
  # Each joystick has zero or more axes, zero or more buttons, zero or more hats,
  # a human-readable name, a user pointer and an SDL compatible GUID.
  #
  # When GLFW is initialized, detected joysticks are added to the beginning of the array.
  # Once a joystick is detected, it keeps its assigned ID until it is disconnected
  # or the library is terminated, so as joysticks are connected and disconnected,
  # there may appear gaps in the IDs.
  #
  # Joystick axis, button, and hat state is updated when polled
  # and does not require a window to be created or events to be processed.
  # However, if you want joystick connection and disconnection events reliably delivered
  # to the joystick `#on_connect` and `#on_disconnect` events, then you must process events.
  struct Joystick
    include ErrorHandling

    JoystickUserData.def_getter

    # Creates a reference to a joystick with the specified ID.
    protected def initialize(@id : LibGLFW::Joystick, @user_data : UserData? = nil)
    end

    # Cleans up resources held by the joystick.
    # Removes the pinned user data.
    protected def destroy!
      return unless user_data = @user_data

      JoystickUserData.instances.delete(user_data)
    end

    # Returns all possible joysticks, connected and disconnected.
    # GLFW supports a maximum of 16 joysticks,
    # so the collection returned by this method always has 16 elements.
    def self.all : Enumerable(Joystick)
      LibGLFW::Joystick.values.map do |id|
        Joystick.new(id)
      end
    end

    # Iterates through all possible joysticks, connected and disconnected.
    # The joystick is yielded to the block.
    def self.each
      LibGLFW::Joystick.each do |id|
        yield Joystick.new(id)
      end
    end

    # Returns a list of all connected joysticks.
    def self.connected : Enumerable(Joystick)
      all.select &.connected?
    end

    # Iterates through all connected joysticks.
    # The joystick is yielded to the block.
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
      value.to_bool
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
    def axes? : Indexable(Float)?
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
    def axes : Indexable(Float)
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
    def buttons? : Indexable(ButtonState)?
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
    def buttons : Indexable(ButtonState)
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
    def hats? : Indexable(JoystickHatState)?
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
    def hats : Indexable(JoystickHatState)
      hats? || raise "Joystick disconnected"
    end

    # Retrieves the name, encoded as UTF-8, of this joystick.
    #
    # If this joystick is not present (`#connected?`),
    # this method will return nil, but will not raise an error.
    # This can be used instead of first calling `#connected?`.
    def name? : String?
      chars = expect_truthy { LibGLFW.get_joystick_name(@id) }
      chars ? String.new(chars) : nil
    end

    # Retrieves the name, encoded as UTF-8, of this joystick.
    #
    # If this joystick is not present (`#connected?`),
    # this method will raise an error.
    def name : String
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
    def guid? : String?
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
    def guid : String
      guid? || raise "Joystick disconnected"
    end

    # Retrieves the current value of the user-defined pointer of this joystick.
    # The initial value is nil.
    #
    # This function may be called from the `#on_disconnect` callback.
    def user_pointer : Pointer
      user_data.pointer
    end

    # Sets the user-defined pointer of this joystick.
    # The current value is retained until the joystick is disconnected.
    # The initial value is nil.
    #
    # This function may be called from the `#on_disconnect` callback.
    def user_pointer=(pointer)
      user_data.pointer = pointer
    end

    # Checks whether this joystick is both present and has a gamepad mapping.
    #
    # If the specified joystick is present (`#connected?`)
    # but does not have a gamepad mapping this method will return false
    # but will not raise an error.
    # Call `#connected?` to check if a joystick is present regardless of whether it has a mapping.
    def gamepad?
      value = expect_truthy { LibGLFW.joystick_is_gamepad(@id) }
      value.to_bool
    end

    # Retrieves the state of the specified joystick remapped to an Xbox-like gamepad.
    #
    # If the specified joystick is not present or does not have a gamepad mapping
    # this method will return nil, but will not raise an error.
    # Call `#connected?` to check whether it is present regardless of whether it has a mapping.
    #
    # See also: `#gamepad?`
    def state? : GamepadState?
      state = uninitialized LibGLFW::GamepadState
      result = expect_truthy { LibGLFW.get_gamepad_state(@id, pointerof(state)) }
      result.to_bool ? GamepadState.new(state) : nil
    end

    # Retrieves the state of the specified joystick remapped to an Xbox-like gamepad.
    #
    # If the specified joystick is not present or does not have a gamepad mapping
    # an error will be raised.
    # Call `#connected?` to check whether it is present regardless of whether it has a mapping.
    #
    # See also: `#gamepad?`
    def state : GamepadState
      state?.not_nil!
    end

    # Parses the specified ASCII encoded *string* and updates the internal list with any gamepad mappings it finds.
    # This string may contain either a single gamepad mapping or many mappings separated by newlines.
    # The parser supports the full format of the `gamecontrollerdb.txt` source file including empty lines and comments.
    #
    # See [Gamepad mappings](https://www.glfw.org/docs/latest/input_guide.html#gamepad_mapping)
    # for a description of the format.
    #
    # If there is already a gamepad mapping for a given GUID in the internal list,
    # it will be replaced by the one passed to this function.
    # If the library is terminated and re-initialized the internal list will revert to the built-in default.
    def self.update_gamepad_mappings(string) : Nil
      expect_truthy { LibGLFW.update_gamepad_mappings(string) }
    end

    # String representation of the joystick.
    def to_s(io)
      io << @id << '(' << name << ')'
    end

    # Returns the underlying joystick ID.
    def to_unsafe
      @id
    end
  end
end
