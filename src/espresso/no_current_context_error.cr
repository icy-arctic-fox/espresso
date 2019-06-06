require "glfw"
require "./glfw_error"

module Espresso
  # Error indicating that GLFW needs an OpenGL context to operate on,
  # but none is currently set on the calling thread.
  #
  # Ensure a context is current before calling functions that require a current context.
  # TODO: Add example on how to do this.
  class NoCurrentContextError < GLFWError
    # Underlying value that represents the error type.
    def code
      LibGLFW::ErrorCode::NoCurrentContext
    end
  end
end
