require "../../user_data"

module Espresso
  # Data stored alongside a joystick instance.
  #
  # Used to store event listeners and pass-through a user pointer.
  private class JoystickUserData < UserData
    protected getter disconnect = JoystickConnectTopic.new

    # Defines a getter method that lazily retrieves/creates the user data.
    macro def_getter(name = :user_data)
      protected getter {{name.id}} do
        # Retrieve the user pointer.
        pointer = checked { LibGLFW.get_joystick_user_pointer(self) }
        # If it references something (the user data)...
        if pointer
          # Unbox it.
          Box(JoystickUserData).unbox(pointer)
        else
          # Otherwise, create new user data and set it.
          JoystickUserData.new.tap do |user_data|
            pointer = Box.box(user_data)
            checked { LibGLFW.set_joystick_user_pointer(self, pointer) }
          end
        end
      end
    end
  end
end
