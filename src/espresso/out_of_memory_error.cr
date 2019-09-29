require "glfw"
require "./glfw_error"

module Espresso
  # Error indicating that GLFW could not allocate memory.
  # This could be a bug in GLFW or the underlying OS.
  class OutOfMemoryError < GLFWError
    # Underlying value that represents the error type.
    def code : LibGLFW::ErrorCode
      LibGLFW::ErrorCode::OutOfMemory
    end
  end
end
