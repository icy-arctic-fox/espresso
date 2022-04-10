require "../user_data"

module Espresso
  # Data stored alongside a window instance.
  #
  # Used to store event listeners and pass-through a user pointer.
  private class WindowUserData < UserData
    protected getter window_move = WindowMoveTopic.new
    protected getter window_resize = WindowResizeTopic.new
    protected getter window_closing = WindowClosingTopic.new
    protected getter window_refresh = WindowRefreshTopic.new
    protected getter window_focus = WindowFocusTopic.new
    protected getter window_iconify = WindowIconifyTopic.new
    protected getter window_maximize = WindowMaximizeTopic.new
    protected getter window_framebuffer_resize = WindowResizeTopic.new
    protected getter window_scale = WindowScaleTopic.new
    protected getter window_drop = WindowDropTopic.new

    # Defines a getter method that lazily retrieves/creates the user data.
    macro def_getter(name = :user_data)
      protected getter {{name.id}} do
        # Retrieve the user pointer.
        pointer = checked { LibGLFW.get_window_user_pointer(self) }
        # If it references something (the user data)...
        if pointer
          # Unbox it.
          Box(WindowUserData).unbox(pointer)
        else
          # Otherwise, create new user data and set it.
          WindowUserData.new.tap do |user_data|
            pointer = Box.box(user_data)
            checked { LibGLFW.set_window_user_pointer(self, pointer) }
          end
        end
      end
    end
  end
end
