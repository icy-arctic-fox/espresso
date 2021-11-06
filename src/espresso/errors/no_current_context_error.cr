require "./glfw_error"

module Espresso
  # Error indicating that GLFW needs an OpenGL context to operate on,
  # but none is currently set on the calling thread.
  #
  # Ensure a context is current before calling functions that require a current context.
  # This can be done with:
  # ```
  # window = Espresso::Window.new(800, 600, "GLFW")
  # window.current!
  # ```
  # or:
  # ```
  # Espresso::Window.open(800, 600) do |window|
  #   # Code that uses the window here.
  # end
  # ```
  class NoCurrentContextError < GLFWError
    # Underlying value that represents the error type.
    def code : LibGLFW::ErrorCode
      LibGLFW::ErrorCode::NoCurrentContext
    end
  end
end
