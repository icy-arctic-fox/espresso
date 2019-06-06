require "glfw"
require "./glfw_error"

module Espresso
  class APIUnavailableError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::APIUnavailable
    end
  end
end
