require "../events/**"
require "./window_topic"

module Espresso
  include WindowTopic

  window_topic set_window_pos_callback, window_move : WindowMoveEvent
  window_topic set_window_size_callback, window_resize : WindowResizeEvent
  window_topic set_window_close_callback, window_closing : WindowClosingEvent
  window_topic set_window_refresh_callback, window_refresh : WindowRefreshEvent
  window_topic set_window_focus_callback, window_focus : WindowFocusEvent
  window_topic set_window_iconify_callback, window_iconify : WindowIconifyEvent
  window_topic set_window_maximize_callback, window_maximize : WindowMaximizeEvent
  window_topic set_framebuffer_size_callback, window_framebuffer_resize : WindowResizeEvent
  window_topic set_window_content_scale_callback, window_scale : WindowScaleEvent
  window_topic set_drop_callback, window_drop : WindowDropEvent
end
