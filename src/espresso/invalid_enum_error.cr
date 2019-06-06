require "glfw"
require "./glfw_error"

module Espresso
  class InvalidEnumError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::InvalidEnum
    end
  end
end
