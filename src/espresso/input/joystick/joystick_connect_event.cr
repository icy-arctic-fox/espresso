module Espresso
  # Event triggered when a joystick connects or disconnects.
  struct JoystickConnectEvent
    # Joystick involved in the event.
    getter joystick : Joystick

    # Flag indicating whether the joystick was connected or not.
    #
    # True means the joystick was connected, false means it was disconnected.
    getter? connected : Bool

    # Creates the joystick connection event.
    protected def initialize(id : LibGLFW::Joystick, event : LibGLFW::DeviceEvent)
      @joystick = Joystick.new(id)
      @connected = event.connected?
    end

    # Flag indicating whether the joystick was disconnected or connected.
    #
    # True means the joystick was disconnected, false means it was connected.
    def disconnected?
      !connected?
    end
  end
end
