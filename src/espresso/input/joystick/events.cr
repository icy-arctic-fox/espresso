require "../../events/**"

module Espresso
  struct Joystick
    # Topic handling joystick connect and disconnect events for all joysticks.
    protected class_getter connect = JoystickConnectTopic.new

    # Registers a listener to respond when a joystick is connected or disconnected.
    # The block of code passed to this method will be invoked when a joystick (dis)connects.
    # The joystick instance will be provided via the event passed as an argument to the block.
    # To remove the listener, call `#remove_connect_listener` with the proc returned by this method.
    def self.on_connect(&block : JoystickConnectEvent ->)
      connect.add_listener(block)
      block
    end

    # Removes a previously registered listener that responded when a joystick is connected or disconnected.
    # The *proc* argument should be the return value of the `#on_connect` method.
    def self.remove_connect_listener(listener : JoystickConnectEvent ->) : Nil
      connect.remove_listener(listener)
    end

    # Registers a listener to respond when this joystick is disconnected.
    # The block of code passed to this method will be invoked when a joystick disconnects.
    # This joystick instance will be provided via the event passed as an argument to the block.
    # To remove the listener, call `#remove_disconnect_listener` with the proc returned by this method.
    def on_disconnect(&block : JoystickConnectEvent ->)
      user_data.disconnect.add_listener(block)
      block
    end

    # Removes a previously registered listener that responded when this joystick is disconnected.
    # The *proc* argument should be the return value of the `#on_disconnect` method.
    def remove_disconnect_listener(listener : JoystickConnectEvent ->) : Nil
      user_data.disconnect.remove_listener(listener)
    end
  end
end
