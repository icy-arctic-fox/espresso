# This file is derived from the `monitors.c` in the GLFW repository.
# https://github.com/glfw/glfw/blob/3.3/tests/clipboard.c

require "opengl"
require "../src/espresso"

{% if flag?(:osx) %}
  MODIFIER = Espresso::ModifierKey::Super
{% else %}
  MODIFIER = Espresso::ModifierKey::Control
{% end %}

Espresso.run do
  Espresso::Window.open(200, 200, "Clipboard Test") do |window|
    Espresso::Window.swap_interval = 1

    window.keyboard.on_key do |event|
      next unless event.pressed?

      case event.key
      when Espresso::Key::Escape
        event.window.closing = true
      when Espresso::Key::V
        if event.mods == MODIFIER
          begin
            string = event.window.clipboard
            puts "Clipboard contains \"#{string}\""
          rescue Espresso::FormatUnavailableError
            puts "Clipboard does not contain a string"
          end
        end
      when Espresso::Key::C
        if event.mods == MODIFIER
          string = "Hello GLFW World!"
          event.window.clipboard = string
          puts "Setting clipboard to \"#{string}\""
        end
      end
    end

    LibGL.clear_color(0.5, 0.5, 0.5, 0)

    until window.closing?
      LibGL.clear(LibGL::ClearBufferMask::ColorBuffer)
      window.swap_buffers
      Espresso::Window.wait_events
    end
  end
end
