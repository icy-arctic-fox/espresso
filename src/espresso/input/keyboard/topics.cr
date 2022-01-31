require "../../events/**"
require "../../window/window_topic"

module Espresso
  include WindowTopic

  window_topic set_key_callback, keyboard_key : KeyboardKeyEvent
  window_topic set_char_callback, keyboard_char : KeyboardCharEvent
  window_topic set_char_mods_callback, keyboard_char_mods : KeyboardCharModsEvent
end
