require "glfw"
require "./glfw_error"

module Espresso
  class OutOfMemoryError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::OutOfMemory
    end
  end
end
