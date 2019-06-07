require "glfw"
require "./glfw_error"

module Espresso
  # Error indicating a value given to a function was not appropriate for its context.
  #
  # This error should not occur with the Espresso wrapper.
  # If it's encountered, it's probably a bug in Espresso and should be reported.
  class InvalidEnumError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::InvalidEnum
    end
  end
end
