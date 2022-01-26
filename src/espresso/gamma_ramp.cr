module Espresso
  # Gamma ramp of a monitor.
  class GammaRamp
    # Array of values describing the response of the red channel.
    getter red : Slice(UInt16)

    # Array of values describing the response of the green channel.
    getter green : Slice(UInt16)

    # Array of values describing the response of the blue channel.
    getter blue : Slice(UInt16)

    # Creates a new gamma ramp with all values set to zero.
    def initialize(size : Int32 = 256)
      @red = Slice.new(size, 0_u16)
      @green = Slice.new(size, 0_u16)
      @blue = Slice.new(size, 0_u16)
    end

    # Creates a new gamma ramp from a pointer to one from GLFW.
    # Contents of the ramp are copied so that they are available
    # even after the monitor is disconnected or GLFW is terminated.
    protected def initialize(pointer : LibGLFW::GammaRamp*)
      ramp = pointer.value
      size = ramp.size.to_i
      # Copy contents of arrays since they may be invalidated when the monitor disconnects.
      @red = Slice(UInt16).new(size).tap(&.copy_from(ramp.red, size))
      @green = Slice(UInt16).new(size).tap(&.copy_from(ramp.green, size))
      @blue = Slice(UInt16).new(size).tap(&.copy_from(ramp.blue, size))
    end

    # Number of elements in each channel's array.
    def size : Int
      @red.size
    end

    # Converts to a GLFW compatible struct.
    def to_unsafe
      ramp = LibGLFW::GammaRamp.new
      ramp.red = @red
      ramp.green = @green
      ramp.blue = @blue
      ramp.size = size
      ramp
    end
  end
end
