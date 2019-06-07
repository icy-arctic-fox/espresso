require "glfw"
require "./glfw_error"

module Espresso
  # Error indicating the requested OpenGL (or OpenGL ES) version is not available on this machine.
  # This also includes any requested context or framebuffer hints.
  #
  # The machine does not support your requirements.
  # If your application is sufficiently flexible,
  # downgrade your requirements and try again.
  # Otherwise, inform the user that their machine does not match your requirements.
  #
  # Future invalid OpenGL and OpenGL ES versions,
  # for example OpenGL 4.8 if 5.0 comes out before the 4.x series gets that far,
  # also fail with this error and not `InvalidValueError`,
  # because GLFW cannot know what future versions will exist.
  class VersionUnavailableError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::VersionUnavailable
    end
  end
end
