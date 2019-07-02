require "glfw"

module Espresso
  enum KeyState
    Released = LibGLFW::Action::Release
    Pressed  = LibGLFW::Action::Press
    Repeated = LibGLFW::Action::Repeat
  end
end
