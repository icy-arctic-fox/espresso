require "./glfw_error"

module Espresso
  # Error indicating a window doesn't have an OpenGL (or OpenGL ES) context.
  # A function was called that requires the specified window to have a context.
  class NoWindowContextError < GLFWError
    # Underlying value that represents the error type.
    def code : LibGLFW::ErrorCode
      LibGLFW::ErrorCode::NoWindowContext
    end
  end
end
