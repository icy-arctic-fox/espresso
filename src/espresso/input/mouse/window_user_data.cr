require "../../events/**"
require "../../user_data"

module Espresso
  private class WindowUserData < UserData
    protected getter mouse_button = MouseButtonTopic.new
    protected getter mouse_move = MouseMoveTopic.new
    protected getter mouse_enter = MouseEnterTopic.new
    protected getter mouse_scroll = MouseScrollTopic.new
  end
end
