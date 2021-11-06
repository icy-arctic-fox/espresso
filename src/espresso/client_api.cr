module Espresso
  enum ClientAPI
    OpenGL   = LibGLFW::ClientAPI::OpenGL
    OpenGLES = LibGLFW::ClientAPI::OpenGLES
    None     = LibGLFW::ClientAPI::None
  end
end
