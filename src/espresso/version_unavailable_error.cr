require "glfw"
require "./glfw_error"

module Espresso
  class VersionUnavailableError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::VersionUnavailable
    end
  end
end
