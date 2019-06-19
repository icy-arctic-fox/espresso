require "glfw"

module Espresso
  enum ContextCreationAPI
    Native = LibGLFW::ContextCreationAPI::Native
    EGL    = LibGLFW::ContextCreationAPI::EGL
    OSMesa = LibGLFW::ContextCreationAPI::OSMesa
  end
end
