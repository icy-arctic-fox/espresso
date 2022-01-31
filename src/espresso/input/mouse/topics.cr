require "../../events/**"
require "../../window/window_topic"

module Espresso
  include WindowTopic

  window_topic set_mouse_button_callback, mouse_button : MouseButtonEvent
  window_topic set_cursor_pos_callback, mouse_move : MouseMoveEvent
  window_topic set_cursor_enter_callback, mouse_enter : MouseEnterEvent
  window_topic set_scroll_callback, mouse_scroll : MouseScrollEvent
end
