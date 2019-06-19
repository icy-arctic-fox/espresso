require "glfw"

module Espresso
  enum ReleaseBehavior
    # The default behavior of the context creation API will be used.
    Any = LibGLFW::ReleaseBehavior::Any

    # The pipeline will be flushed whenever the context is released from being the current one.
    Flush = LibGLFW::ReleaseBehavior::Flush

    # The pipeline will not be flushed on release.
    None = LibGLFW::ReleaseBehavior::None
  end
end
