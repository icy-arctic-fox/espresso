require "../../error_handling"
require "../../topic"
require "./joystick_connect_event"

module Espresso
  struct Joystick
    # Tracks subscriptions and delegates joystick connection events.
    private struct ConnectTopic < Topic(JoystickConnectEvent)
      include ErrorHandling

      private def register_callback(*_args)
        checked { LibGLFW.set_joystick_callback(->ConnectTopic.call) }
      end

      private def unregister_callback(*_args)
        checked { LibGLFW.set_joystick_callback(nil) }
      end

      # Method that GLFW will call when a joystick connection event occurs.
      # Constructs the event and publishes it to listeners.
      protected def self.call(*args)
        event = JoystickConnectEvent.new(*args)
        Joystick.connect.call(event)

        if event.disconnected?
          event.joystick.user_data.disconnect.call(event)
          event.joystick.destroy!
        end
      end
    end

    class UserData
      getter disconnect = ConnectTopic.new
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

    # Topic handling joystick connect and disconnect events for all joysticks.
    protected class_getter connect = ConnectTopic.new

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
  end
end
