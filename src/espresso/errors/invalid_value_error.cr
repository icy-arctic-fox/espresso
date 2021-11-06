require "./glfw_error"

module Espresso
  # Error indicating one of the arguments to the function was an invalid value.
  # For example, requesting a non-existent OpenGL (or OpenGL ES) version, like 2.7.
  #
  # Requesting a valid, but unavailable OpenGL (or OpenGL ES ) version
  # will instead raise `VersionUnavailableError`.
  class InvalidValueError < GLFWError
    # Underlying value that represents the error type.
    def code : LibGLFW::ErrorCode
      LibGLFW::ErrorCode::InvalidValue
    end
  end
end
