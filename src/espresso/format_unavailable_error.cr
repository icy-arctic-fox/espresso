require "glfw"
require "./glfw_error"

module Espresso
  # Error indicating the desired format is not supported or understood.
  # If emitted during window creation,
  # the requested pixel format is not supported.
  # If emitted when querying the clipboard,
  # the contents of the clipboard could not be converted to the requested format.
  #
  # If emitted during window creation,
  # one or more hard constraints did not match any of the available pixel formats.
  # If your application is sufficiently flexible,
  # downgrade your requirements and try again.
  # Otherwise, inform the user that their machine does not match your requirements.
  #
  # If emitted when querying the clipboard,
  # ignore the error or report it to the user, as appropriate.
  class FormatUnavailableError < GLFWError
    # Underlying value that represents the error type.
    def code : LibGLFW::ErrorCode
      LibGLFW::ErrorCode::FormatUnavailable
    end
  end
end
