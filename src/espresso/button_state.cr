require "glfw"

module Espresso
  enum ButtonState
    Released = LibGLFW::Action::Release
    Pressed  = LibGLFW::Action::Press
  end
end
