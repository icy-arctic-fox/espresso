record Screen, width : Int32, height : Int32

record VideoMode, width : Int32, height : Int32, rate : Int32, current : Bool

record Monitor, width : Int32, height : Int32, x : Int32, y : Int32,
  width_mm : Int32, height_mm : Int32, primary : Bool, name : String,
  video_modes : Array(VideoMode), connected : Bool

# Runs the xrandr command to get display information.
module XRandR
  extend self

  # Retrieve display information.
  def info
    lines = `xrandr 2>/dev/null`.lines
    raise "No output from xrandr - is it installed?" if lines.empty?

    screen_info = lines.shift
    m = screen_info.match(/^Screen \d+: minimum \d+ x \d+, current (\d+) x (\d+), maximum \d+ x \d+/)
    raise "Unexpected output from xrandr" unless m

    screen = Screen.new(width: m[1].to_i, height: m[2].to_i)
    monitors = monitor_info(lines)

    {screen: screen, monitors: monitors}
  end

  private def monitor_info(lines)
    Array(Monitor).new.tap do |monitors|
      until lines.empty?
        monitor_info = lines.shift
        video_mode_lines = lines.take_while(&.starts_with?(' '))
        lines.shift(video_mode_lines.size)

        video_modes = parse_video_modes(video_mode_lines)
        monitors << parse_monitor_info(monitor_info, video_modes)
      end
    end
  end

  private def parse_video_modes(lines)
    Array(VideoMode).new.tap do |modes|
      lines.each do |line|
        rates = line.strip.split
        resolution = rates.shift
        width, height = resolution.split('x', 2)
        rates.each do |rate|
          current = rate.includes?('*')
          if (m = rate.match(/\d+\.\d+/))
            r = m[0].to_f32.round.to_i
            modes << VideoMode.new(width.to_i, height.to_i, r, current)
          end
        end
      end
      modes.uniq!
    end
  end

  private def parse_monitor_info(info_line, video_modes)
    if (m = info_line.match(/^(.*?) connected( primary)? (\d+)x(\d+)\+(\d+)\+(\d+)/))
      name = m[1]
      primary = !!m[2]?
      width = m[3].to_i
      height = m[4].to_i
      x = m[5].to_i
      y = m[6].to_i
      width_mm, height_mm = 0, 0
      if m = info_line.match(/(\d+)mm x (\d+)mm$/)
        width_mm = m[1].to_i
        height_mm = m[2].to_i
      end
      Monitor.new(width, height, x, y, width_mm, height_mm, primary, name, video_modes, true)
    elsif (m = info_line.match(/^(.*?) disconnected/))
      name = m[1]
      Monitor.new(0, 0, 0, 0, 0, 0, false, name, video_modes, false)
    else
      raise "Failed to match monitor info"
    end
  end
end
