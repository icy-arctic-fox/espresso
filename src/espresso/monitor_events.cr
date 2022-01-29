require "./error_handling"
require "./monitor_connect_event"
require "./topic"

module Espresso
  struct Monitor
    # Tracks subscriptions and delegates monitor connection events.
    private struct MonitorConnectTopic < Topic(MonitorConnectEvent)
      include ErrorHandling

      private def register_callback(*_args)
        checked { LibGLFW.set_monitor_callback(->MonitorConnectTopic.call) }
      end

      private def unregister_callback(*_args)
        checked { LibGLFW.set_monitor_callback(nil) }
      end

      # Method that GLFW will call when a monitor connection event occurs.
      # Constructs the event and publishes it to listeners.
      protected def self.call(*args)
        Monitor.connect.call { MonitorConnectEvent.new(*args) }
      end
    end

    # Topic handling monitor connect and disconnect events for all monitors.
    protected class_getter connect = MonitorConnectTopic.new

    # Registers a listener to respond when a monitor is connected or disconnected.
    # The block of code passed to this method will be invoked when a monitor (dis)connects.
    # The monitor instance will be provided as an argument to the block.
    # To remove the listener, call `#remove_connect_listener` with the proc returned by this method.
    def self.on_connect(&block : MonitorConnectEvent ->)
      connect.add_listener(block)
      block
    end

    # Removes a previously registered listener that responded when a monitor is connected or disconnected.
    # The *proc* argument should be the return value of the `#on_connect` method.
    def self.remove_connect_listener(listener : MonitorConnectEvent ->) : Nil
      connect.remove_listener(listener)
    end
  end
end
