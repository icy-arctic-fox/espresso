require "./bounds"
require "./error_handling"
require "./gamma_ramp"
require "./invalid_value_error"
require "./position"
require "./scale"
require "./size"
require "./video_mode"

module Espresso
  # Reference to a display monitor or screen and information about it.
  #
  # Instances of this type cannot be created by the end-user.
  # To retrieve a monitor, use the `#primary` or `#all` methods.
  struct Monitor
    include ErrorHandling

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
      count = uninitialized Int32
      pointers = ErrorHandling.static_expect_truthy { LibGLFW.get_monitors(pointerof(count)) }
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

    # Size, in screen coordinates, of the monitor.
    #
    # Can raise a `PlatformError`.
    def size
      current_video_mode.size
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

    # Physical size of a monitor in millimeters, or an estimation of it.
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

    # Retrieves the current value of the user-defined pointer for this monitor.
    # This can be used for any purpose you need and will not be modified by GLFW.
    # The value will be kept until the monitor is disconnected or until the library is terminated.
    # The initial value is nil.
    #
    # This method may be called from the monitor connect/disconnect event,
    # even if the monitor is being disconnected.
    def user_pointer
      checked { LibGLFW.get_monitor_user_pointer(@pointer) }
    end

    # Updates the value of the user-defined pointer for this monitor.
    # This can be used for any purpose you need and will not be modified by GLFW.
    # The value will be kept until the monitor is disconnected or until the library is terminated.
    # The initial value is nil.
    def user_pointer=(pointer)
      checked { LibGLFW.set_monitor_user_pointer(@pointer, pointer) }
    end

    # List of all video modes supported by the monitor.
    # The returned array is sorted in ascending order,
    # first by color bit depth (the sum of all channel depths)
    # and then by resolution area (the product of width and height).
    #
    # Can raise a `PlatformError`.
    def video_modes
      count = uninitialized Int32
      video_modes_pointer = expect_truthy { LibGLFW.get_video_modes(@pointer, pointerof(count)) }
      video_modes = Slice.new(video_modes_pointer, count, read_only: true)
      video_modes.map { |video_mode| VideoMode.new(video_mode) }
    end

    # Retrieves the currently active video mode for the monitor.
    #
    # If there is a full-screen window, and it isn't iconified,
    # the video mode returned will match the window's video mode.
    #
    # Can raise a `PlatformError`.
    def current_video_mode
      video_mode_pointer = expect_truthy { LibGLFW.get_video_mode(@pointer) }
      VideoMode.new(video_mode_pointer.value)
    end

    # Adjusts the gamma ramp for the monitor.
    # The *gamma* argument is the desired exponent.
    # GLFW will compute a normal gamma ramp and apply it.
    #
    # The software controlled gamma ramp is applied in addition to the hardware gamma correction,
    # which today is usually an approximation of sRGB gamma.
    # This means that setting a perfectly linear ramp, or gamma 1.0,
    # will produce the default (usually sRGB-like) behavior.
    #
    # Can raise a `PlatformError`.
    # Raises an `ArgumentError` if the *gamma* value is invalid.
    def gamma=(gamma)
      checked { LibGLFW.set_gamma(@pointer, gamma) }
    rescue e : InvalidValueError
      raise ArgumentError.new("Invalid gamma value")
    end

    # Retrieves the current gamma ramp for the monitor.
    #
    # On Wayland, gamma handling is a privileged protocol,
    # and this method will always raise `PlatformError`.
    #
    # Can raise a `PlatformError`.
    def gamma_ramp
      ramp_pointer = expect_truthy { LibGLFW.get_gamma_ramp(@pointer) }
      GammaRamp.new(ramp_pointer)
    end

    # Sets the gamma ramp to be used for the monitor.
    # The original gamma ramp for that monitor is saved by GLFW
    # the first time this function is called and is restored
    # when GLFW is terminated (`Espresso.terminate`).
    #
    # The software controlled gamma ramp is applied in addition to the hardware gamma correction,
    # which today is usually an approximation of sRGB gamma.
    # This means that setting a perfectly linear ramp, or gamma 1.0,
    # will produce the default (usually sRGB-like) behavior.
    #
    # For gamma correct rendering with OpenGL or OpenGL ES, see the GLFW_SRGB_CAPABLE hint.
    #
    # The size of the specified gamma ramp should match the size of the current ramp for this monitor.
    # On Windows, the gamma ramp size must be 256.
    # On Wayland, gamma handling is a privileged protocol,
    # and this method will always raise `PlatformError`.
    #
    # Can raise a `PlatformError`.
    def gamma_ramp=(ramp)
      glfw_ramp = ramp.to_unsafe
      checked { LibGLFW.set_gamma_ramp(@pointer, pointerof(glfw_ramp)) }
    end

    # String representation of the monitor.
    def to_s(io)
      io << "Monitor("
      io << name
      io << ')'
    end

    # Returns the underlying GLFW monitor pointer.
    def to_unsafe
      @pointer
    end

    # Stores active listeners for connect and disconnect events.
    # GLFW has only one callback, which is when any monitor connects or disconnects.
    # But it is split here for end-user convenience.
    @@class_connect_listeners = [] of self ->
    @@class_disconnect_listeners = [] of self ->
    @@disconnect_listeners = {} of LibGLFW::Monitor => Array(self ->)

    # Checks if there are any registered listeners.
    protected def self.any_listeners?
      !(@@class_connect_listeners.empty? &&
        @@class_disconnect_listeners.empty? &&
        @@disconnect_listeners.empty?)
    end

    # Method that is called by GLFW when any monitor event occurs.
    protected def self.monitor_callback(pointer, event)
      monitor = Monitor.new(pointer)
      case event
      when LibGLFW::DeviceEvent::Connected
        # Call all class-level listeners.
        @@class_connect_listeners.each(&.call(monitor))
      when LibGLFW::DeviceEvent::Disconnected
        # Call all class-level listeners.
        @@class_disconnect_listeners.each(&.call(monitor))

        # Check if there's any instance-level listeners and call them.
        if (listeners = @@disconnect_listeners[pointer]?)
          listeners.each(&.call(monitor))

          # Instance-level disconnect listeners must be handled differently.
          # When the monitor disconnects, the address/pointer/handle to it is no longer valid.
          # So all of the listeners for that monitor must be removed.
          @@disconnect_listeners.delete(monitor)
        end
      else
        raise "Unknown monitor device event - #{event}"
      end
    end

    # Registers a listener to respond when a monitor is connected.
    # The block of code passed to this method will be invoked when a monitor is connected.
    # The monitor instance will be provided as an argument to the block.
    # To remove the listener, call `#remove_connect_listener` with the proc returned by this method.
    def self.on_connect(&block : self ->)
      LibGLFW.set_monitor_callback(->monitor_callback) unless any_listeners?
      @@class_connect_listeners << block
      block
    end

    # Removes a previously registered listener that responded when a monitor is connected.
    # The *proc* argument should be the return value of the `#on_connect` method.
    def self.remove_connect_listener(proc : self ->) : Nil
      @@class_connect_listeners.delete(proc)
      LibGLFW.set_monitor_callback(nil) unless any_listeners?
    end

    # Registers a listener to respond when any monitor is disconnected.
    # The block of code passed to this method will be invoked when a monitor is disconnected.
    # The monitor instance will be provided as an argument to the block.
    # To remove the listener, call `#remove_disconnect_listener` with the proc returned by this method.
    def self.on_disconnect(&block : self ->)
      LibGLFW.set_monitor_callback(->monitor_callback) unless any_listeners?
      @@class_disconnect_listeners << block
      block
    end

    # Removes a previously registered listener that responded when a monitor is disconnected.
    # The *proc* argument should be the return value of the `#on_disconnect` method.
    def self.remove_disconnect_listener(proc : self ->) : Nil
      @@class_disconnect_listeners.delete(proc)
      LibGLFW.set_monitor_callback(nil) unless any_listeners?
    end

    # Registers a listener to respond when this monitor is disconnected.
    # The block of code passed to this method will be invoked when the monitor is disconnected.
    # The monitor instance (this) will be provided as an argument to the block.
    # To remove the listener, call `#remove_disconnect_listener` with the proc returned by this method.
    # All registered listeners will be automatically removed
    # after they have been called and this monitor is disconnected.
    def on_disconnect(&block : self ->)
      LibGLFW.set_monitor_callback(->Monitor.monitor_callback) unless Monitor.any_listeners?
      if (listeners = @@disconnect_listeners[@pointer]?)
        listeners << block
      else
        @@disconnect_listeners[@pointer] = [block]
      end
      block
    end

    # Removes a previously registered listener that responded when this monitor is disconnected.
    # The *proc* argument should be the return value of the `#on_disconnect` method.
    def remove_disconnect_listener(proc : self ->) : Nil
      return unless (listeners = @@disconnect_listeners[@pointer]?)

      listeners.delete(proc)
      @@disconnect_listeners.delete(@pointer) if listeners.empty?
      LibGLFW.set_monitor_callback(nil) unless Monitor.any_listeners?
    end
  end
end
