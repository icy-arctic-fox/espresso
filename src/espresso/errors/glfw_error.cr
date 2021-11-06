module Espresso
  # Base class for all possible GLFW errors.
  abstract class GLFWError < Exception
    # Underlying value that represents the error type.
    abstract def code : LibGLFW::ErrorCode
  end
end
