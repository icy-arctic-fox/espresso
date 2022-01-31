require "../../events/**"
require "../../user_data"

module Espresso
  private class WindowUserData < UserData
    protected getter keyboard_key = KeyboardKeyTopic.new
    protected getter keyboard_char = KeyboardCharTopic.new
    protected getter keyboard_char_mods = KeyboardCharModsTopic.new
  end
end
