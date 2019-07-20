# This file is derived from the `monitors.c` in the GLFW repository.
# https://github.com/glfw/glfw/blob/3.3/tests/monitors.c

require "opengl"
require "option_parser"
require "../src/espresso"

enum Mode
  List
  Test
end

def list_modes(monitor)
  current = monitor.current_video_mode
  modes = monitor.video_modes

  pos = monitor.position
  size_mm = monitor.physical_size
  scale = monitor.content_scale
  workarea = monitor.workarea

  puts "Name: #{monitor.name} (#{Espresso::Monitor.primary == monitor ? "primary" : "secondary"})"
  puts "Current mode: #{current}"
  puts "Virtual position: #{pos.x} #{pos.y}"
  puts "Content scale: #{scale.x} #{scale.y}"

  puts "Physical size: #{size_mm.width} x #{size_mm.height} mm (#{current.width * 25.4 / size_mm.width} dpi)"
  puts "Monitor work area: pos=(#{workarea.x},#{workarea.y}) size=(#{workarea.width}x#{workarea.height})"

  puts "Modes:"
  modes.each_with_index do |mode, index|
    printf("%3i: %s", index, mode)
    print " (current mode)" if mode == current
    puts
  end
end

def test_modes(monitor)
  modes = monitor.video_modes
  modes.each_with_index do |mode, index|
    builder = Espresso::WindowBuilder.new
    builder.red_bits = mode.red
    builder.green_bits = mode.green
    builder.blue_bits = mode.blue
    builder.refresh_rate = mode.refresh_rate

    puts "Testing mode #{index} on monitor #{monitor.name}: #{mode}"

    window = begin
      builder.build_full_screen("Video Mode Test", monitor, mode.width, mode.height)
    rescue
      puts "Failed to enter mode #{index}: #{mode}"
      next
    end

    window.on_framebuffer_resize do |event|
      puts "Framebuffer resized to #{event.width}x#{event.height}"
      LibGL.viewport(0, 0, event.width, event.height)
    end

    window.keyboard.on_key do |event|
      event.window.closing = true if event.key.escape?
    end

    window.current!
    Espresso::Window.swap_interval = 1

    Espresso::Timer.global = 0.0

    while Espresso::Timer.global < 5.0
      LibGL.clear(LibGL::ClearBufferMask::ColorBuffer)
      window.swap_buffers
      Espresso::Window.poll_events

      if window.closing?
        puts "User terminated program"
        Espresso.terminate
        exit
      end
    end

    LibGL.get_integer_v(LibGL::GetPName.new(0x0D52), out red)
    LibGL.get_integer_v(LibGL::GetPName.new(0x0D53), out green)
    LibGL.get_integer_v(LibGL::GetPName.new(0x0D54), out blue)

    size = window.size

    if red != mode.red ||
       green != mode.green ||
       blue != mode.blue
      puts "*** Color bit mismatch: (#{red} #{green} #{blue}) instead of (#{mode.red} #{mode.green} #{mode.blue})"
    end

    if size.width != mode.width || size.height != mode.height
      puts "*** Size mismatch: #{size} instead of #{mode.size}"
    end

    puts "Closing window"

    window.destroy!

    Espresso::Window.poll_events
  end
end

Espresso.run do
  Espresso::Monitor.all.each do |monitor|
    mode = Mode::List
    OptionParser.parse! do |parser|
      parser.on("-t", "Test mode") { mode = Mode::Test }
      parser.on("-h", "Display help") do
        puts parser
        exit
      end
      parser.invalid_option do
        puts parser
        exit(1)
      end
    end

    if mode == Mode::List
      list_modes(monitor)
    elsif mode == Mode::Test
      test_modes(monitor)
    end
  end
end
