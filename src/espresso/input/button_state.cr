module Espresso
  enum ButtonState : UInt8
    Released = LibGLFW::Action::Release
    Pressed  = LibGLFW::Action::Press
  end
end
