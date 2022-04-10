module Espresso
  # Gamma ramp of a monitor.
  struct GammaRamp
    # Number of elements in each channel's array.
    getter size : Int32

    @ramp : Pointer(UInt16)

    # Creates a new gamma ramp with all values set to zero.
    def initialize(@size : Int32 = 256)
      @ramp = Pointer(UInt16).malloc(@size * 3)
    end

    # Creates a new gamma ramp from a pointer to one from GLFW.
    # Contents of the ramp are copied so that they are available
    # even after the monitor is disconnected or GLFW is terminated.
    protected def initialize(pointer : LibGLFW::GammaRamp*)
      source = pointer.value
      @size = source.size.to_i

      # Copy contents of arrays since they may be invalidated when the monitor disconnects.
      @ramp = Pointer(UInt16).malloc(@size * 3)
      red_pointer.copy_from(source.red, @size)
      green_pointer.copy_from(source.green, @size)
      blue_pointer.copy_from(source.blue, @size)
    end

    # Array of values describing the response of the red channel.
    def red : Slice(UInt16)
      red_pointer.to_slice(@size)
    end

    # Pointer to the start of the red channel data.
    @[AlwaysInline]
    private def red_pointer : Pointer(UInt16)
      @ramp
    end

    # Array of values describing the response of the green channel.
    def green : Slice(UInt16)
      green_pointer.to_slice(@size)
    end

    # Pointer to the start of the green channel data.
    @[AlwaysInline]
    private def green_pointer : Pointer(UInt16)
      @ramp + @size
    end

    # Array of values describing the response of the blue channel.
    def blue : Slice(UInt16)
      blue_pointer.to_slice(@size)
    end

    # Pointer to the start of the blue channel data.
    @[AlwaysInline]
    private def blue_pointer : Pointer(UInt16)
      @ramp + @size + @size
    end

    # Converts to a GLFW compatible struct.
    def to_unsafe
      ramp = LibGLFW::GammaRamp.new
      ramp.red = red_pointer
      ramp.green = green_pointer
      ramp.blue = blue_pointer
      ramp.size = @size
      ramp
    end
  end
end
