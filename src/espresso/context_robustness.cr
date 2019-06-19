require "glfw"

module Espresso
  enum ContextRobustness
    LoseContextOnReset  = LibGLFW::ContextRobustness::LoseContextOnReset
    NoResetNotification = LibGLFW::ContextRobustness::NoResetNotification
    None                = LibGLFW::ContextRobustness::None
  end
end
