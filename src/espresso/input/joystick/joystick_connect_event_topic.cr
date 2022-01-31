require "../../class_topic"
require "../../error_handling"

module Espresso
  # Tracks subscriptions and delegates joystick connection events.
  private struct JoystickConnectTopic < ClassTopic(JoystickConnectEvent)
    include ErrorHandling

    private def register_callback
      checked { LibGLFW.set_joystick_callback(->JoystickConnectEventTopic.call) }
    end

    private def unregister_callback
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
end
