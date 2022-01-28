require "./size"

module Espresso
  # Information about the size, color depth, and refresh rate of a monitor.
  struct VideoMode
    # The width, in screen coordinates, of the video mode.
    getter width : Int32

    # The height, in screen coordinates, of the video mode.
    getter height : Int32

    # The bit depth of the red channel of the video mode.
    getter red : Int32

    # The bit depth of the green channel of the video mode.
    getter green : Int32

    # The bit depth of the blue channel of the video mode.
    getter blue : Int32

    # The refresh rate, in Hz, of the video mode.
    getter refresh_rate : Int32

    # Creates a new video mode.
    # This initializer is typically used for constructing a desired video mode.
    # Then the desired video mode can be compared against supported modes with `#==`.
    def initialize(@width, @height, @red, @green, @blue, @refresh_rate)
    end

    # Creates a video mode from an existing one.
    # Copies the values from a GLFW struct.
    protected def initialize(video_mode : LibGLFW::VideoMode)
      @width = video_mode.width
      @height = video_mode.height
      @red = video_mode.red_bits
      @green = video_mode.green_bits
      @blue = video_mode.blue_bits
      @refresh_rate = video_mode.refresh_rate
    end

    # Width and height of the video mode.
    def size : Size
      Size.new(@width, @height)
    end

    # Total color depth of all channels.
    def depth : Int
      @red + @blue + @green
    end

    # Creates a string representation of the video mode.
    def to_s(io)
      io << @width << 'x' << @height << 'x' << depth
      io << '@' << @refresh_rate << "Hz (R"
      io << @red << 'G' << @green << 'B' << @blue << ')'
    end
  end
end
