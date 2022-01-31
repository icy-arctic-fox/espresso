module Espresso
  # Event triggered when a monitor connects or disconnects.
  struct MonitorConnectEvent
    # Monitor involved in the event.
    getter monitor : Monitor

    # Flag indicating whether the monitor was connected or not.
    #
    # True means the monitor was connected, false means it was disconnected.
    getter? connected : Bool

    # Creates the monitor connection event.
    protected def initialize(pointer : LibGLFW::Monitor, event : LibGLFW::DeviceEvent)
      @monitor = Monitor.new(pointer)
      @connected = event.connected?
    end

    # Flag indicating whether the monitor was disconnected or connected.
    #
    # True means the monitor was disconnected, false means it was connected.
    def disconnected?
      !connected?
    end
  end
end
