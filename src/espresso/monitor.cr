require "./error_handling"

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

    def position
      raise NotImplementedError.new("#position")
    end

    def workarea
      raise NotImplementedError.new("#workarea")
    end

    def physical_size
      raise NotImplementedError.new("#physical_size")
    end

    def content_scale
      raise NotImplementedError.new("#content_scale")
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
