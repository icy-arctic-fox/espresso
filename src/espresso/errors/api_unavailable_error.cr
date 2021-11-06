require "./glfw_error"

module Espresso
  # Error indicating GLFW could not find support for the requested API.
  #
  # The installed graphics driver does not support the requested API,
  # or does not support it via the chosen context creation backend.
  # Below are a few examples:
  # - Some pre-installed Windows graphics drivers do not support OpenGL.
  # - AMD only supports OpenGL ES via EGL,
  #   while Nvidia and Intel only support it via a WGL or GLX extension.
  # - macOS does not provide OpenGL ES at all.
  # - The Mesa EGL, OpenGL and OpenGL ES libraries do not interface
  #   with the Nvidia binary driver.
  # - Older graphics drivers do not support Vulkan.
  class APIUnavailableError < GLFWError
    # Underlying value that represents the error type.
    def code : LibGLFW::ErrorCode
      LibGLFW::ErrorCode::APIUnavailable
    end
  end
end
