require "glfw"
require "./glfw_error"

module Espresso
  # Error indicating that GLFW had a problem running on the current system/platform.
  # This can be due to multiple things:
  # - A bug or configuration error in GLFW
  # - The underlying OS or drivers
  # - Lack of required resources
  class PlatformError < GLFWError
    # Underlying value that represents the error type.
    def code : LibGLFW::ErrorCode
      LibGLFW::ErrorCode::PlatformError
    end
  end
end
