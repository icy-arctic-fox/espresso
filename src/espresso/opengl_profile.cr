require "glfw"

module Espresso
  enum OpenGLProfile
    Core   = LibGLFW::OpenGLProfile::Core
    Compat = LibGLFW::OpenGLProfile::Compat
    Any    = LibGLFW::OpenGLProfile::Any
  end
end
