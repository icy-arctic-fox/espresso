require "./bounds"
require "./error_handling"
require "./position"
require "./scale"
require "./size"

module Espresso
  # Reference to a display monitor or screen and information about it.
  #
  # Instances of this type cannot be created by the end-user.
  # To retrieve a monitor, use the `#primary` or `#all` methods.
  struct Monitor
    include ErrorHandling

    # TODO: Add event for connect/disconnect.

    # Constructs the monitor reference with a *pointer* from GLFW.
    protected def initialize(@pointer : LibGLFW::Monitor)
    end

    # Attempts to retrieve the user's primary monitor.
    # If there's no monitors, then this returns nil.
    def self.primary?
      pointer = ErrorHandling.static_expect_truthy { LibGLFW.get_primary_monitor }
      pointer ? Monitor.new(pointer) : nil
    end

    # Retrieves the user's primary monitor.
    # If there are no monitors, then a `NilAssertionError` will be raised.
    def self.primary
      primary?.not_nil!
    end

    # Retrieves all of the monitors connected to the user's system.
    # This returns an array of `Monitor` instances.
    #
    # The primary monitor is always the first monitor in the returned array,
    # but other monitors may be moved to a different index
    # when a monitor is connected or disconnected.
    def self.all
      count = 0
      pointers = expect_truthy { LibGLFW.get_monitors(pointerof(count)) }
      return [] of Monitor unless pointers # nil is returned if there's no monitors.

      # Use a slice to safely traverse the C-style array.
      # Map the pointers to Monitor structs.
      slice = Slice.new(pointers, count, read_only: true)
      slice.map { |pointer| Monitor.new(pointer) }
    end

    # Position, in screen coordinates, of the upper-left corner of the monitor.
    # This is the position of the monitor on the virtual desktop.
    #
    # Can raise a `PlatformError`.
    def position
      checked do
        LibGLFW.get_monitor_pos(@pointer, out x, out y)
        Position.new(x, y)
      end
    end

    # Area of a monitor not occupied by global task bars or menu bars.
    # This is specified in screen coordinates.
    #
    # Can raise a `PlatformError`.
    def workarea
      checked do
        LibGLFW.get_monitor_workarea(@pointer, out x, out y, out width, out height)
        Bounds.new(x, y, width, height)
      end
    end

    # Physical size of a monitor in millimetres, or an estimation of it.
    #
    # While this can be used to calculate the raw DPI of a monitor, this is often not useful.
    # Instead use `#content_scale` and `Window#content_scale` to scale your content.
    #
    # Some systems do not provide accurate monitor size information,
    # either because the monitor EDID data is incorrect
    # or because the driver does not report it accurately.
    # On Windows, the physical size is calculated from the current resolution
    # and system DPI instead of querying the monitor EDID data.
    def physical_size
      checked do
        LibGLFW.get_monitor_physical_size(@pointer, out width, out height)
        Size.new(width, height)
      end
    end

    # Ratio between the current DPI and the platform's default DPI.
    # This is especially important for text and any UI elements.
    # If the pixel dimensions of your UI scaled by this look appropriate on your machine
    # then it should appear at a reasonable size on other machines regardless of their DPI and scaling settings.
    # This relies on the system DPI and scaling settings being somewhat correct.
    #
    # The content scale may depend on both the monitor resolution and pixel density and on user settings.
    # It may be very different from the raw DPI calculated from the physical size and current resolution.
    #
    # Can raise a `PlatformError`.
    #
    # See also: `Window#content_scale`
    def content_scale
      checked do
        LibGLFW.get_monitor_content_scale(@pointer, out x, out y)
        Scale.new(x, y)
      end
    end

    # Retrieves the human-readable name of the monitor.
    # The name typically reflects the make and model of the monitor
    # and is not guaranteed to be unique among the connected monitors.
    #
    # Only the monitor handle is guaranteed to be unique,
    # and only until that monitor is disconnected.
    # If you want to compare monitors, use the `==` operator.
    def name
      c_string = expect_truthy { LibGLFW.get_monitor_name(@pointer) }
      String.new(c_string)
    end

    def user_pointer
      raise NotImplementedError.new("#user_pointer")
    end

    def user_pointer=(pointer)
      raise NotImplementedError.new("#user_pointer=")
    end

    def video_modes
      raise NotImplementedError.new("#video_modes")
    end

    def primary_video_mode
      raise NotImplementedError.new("#primary_video_mode")
    end

    def gamma=(gamma)
      raise NotImplementedError.new("#gamma=")
    end

    def gamma_ramp
      raise NotImplementedError.new("#gamma_ramp")
    end

    def gamma_ramp=(ramp)
      raise NotImplementedError.new("#gamma_ramp=")
    end
  end
end
