require "../user_data"

module Espresso
  # Data stored alongside a monitor instance.
  #
  # Used to store event listeners and pass-through a user pointer.
  private class MonitorUserData < UserData
    protected getter disconnect = MonitorConnectTopic.new

    # Defines a getter method that lazily retrieves/creates the user data.
    macro def_getter(name = :user_data)
      protected getter {{name.id}} do
        # Retrieve the user pointer.
        pointer = checked { LibGLFW.get_monitor_user_pointer(self) }
        # If it references something (the user data)...
        if pointer
          # Unbox it.
          Box(MonitorUserData).unbox(pointer)
        else
          # Otherwise, create new user data and set it.
          MonitorUserData.new.tap do |user_data|
            box = Box.box(user_data)
            checked { LibGLFW.set_monitor_user_pointer(self, box) }
          end
        end
      end
    end
  end
end
