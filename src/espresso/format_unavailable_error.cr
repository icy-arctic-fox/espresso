require "glfw"
require "./glfw_error"

module Espresso
  class FormatUnavailableError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::FormatUnavailable
    end
  end
end
