require "glfw"
require "./glfw_error"

module Espresso
  # Error indicating that GLFW has not been initialized.
  #
  # Initialize GLFW before calling any function that requires initialization.
  # This can be done with:
  # ```
  # Espresso.init
  # # Code that uses GLFW here.
  # Espresso.terminate
  # ```
  # or:
  # ```
  # Espresso.run do
  #   # Code that uses GLFW here.
  # end
  # ```
  class NotInitializedError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::NotInitialized
    end
  end
end
