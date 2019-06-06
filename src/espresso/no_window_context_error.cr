require "glfw"
require "./glfw_error"

module Espresso
  class NoWindowContextError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::NoWindowContext
    end
  end
end
