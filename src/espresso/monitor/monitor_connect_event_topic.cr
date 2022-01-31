require "../class_topic"
require "../error_handling"

module Espresso
  # Tracks subscriptions and delegates monitor connection events.
  private struct MonitorConnectTopic < ClassTopic(MonitorConnectEvent)
    include ErrorHandling

    private def register_callback
      checked { LibGLFW.set_monitor_callback(->MonitorConnectTopic.call) }
    end

    private def unregister_callback
      checked { LibGLFW.set_monitor_callback(nil) }
    end

    # Method that GLFW will call when a monitor connection event occurs.
    # Constructs the event and publishes it to listeners.
    protected def self.call(*args)
      event = MonitorConnectEvent.new(*args)
      Monitor.connect.call(event)

      if event.disconnected?
        event.monitor.user_data.disconnect.call(event)
        event.monitor.destroy!
      end
    end
  end
end
