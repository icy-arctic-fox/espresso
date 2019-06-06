require "glfw"
require "./glfw_error"

module Espresso
  class InvalidValueError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::InvalidValue
    end
  end
end
