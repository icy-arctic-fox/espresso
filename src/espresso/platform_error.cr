require "glfw"
require "./glfw_error"

module Espresso
  class PlatformError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::PlatformError
    end
  end
end
