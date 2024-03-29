require "../events/**"

module Espresso
  struct Monitor
    # Topic handling monitor connect and disconnect events for all monitors.
    protected class_getter connect = MonitorConnectTopic.new

    # Registers a listener to respond when a monitor is connected or disconnected.
    # The block of code passed to this method will be invoked when a monitor (dis)connects.
    # The monitor instance will be provided via the event passed as an argument to the block.
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

    # Registers a listener to respond when this monitor is disconnected.
    # The block of code passed to this method will be invoked when a monitor disconnects.
    # This monitor instance will be provided via the event passed as an argument to the block.
    # To remove the listener, call `#remove_disconnect_listener` with the proc returned by this method.
    def on_disconnect(&block : MonitorConnectEvent ->)
      user_data.disconnect.add_listener(block)
      block
    end

    # Removes a previously registered listener that responded when this monitor is disconnected.
    # The *proc* argument should be the return value of the `#on_disconnect` method.
    def remove_disconnect_listener(listener : MonitorConnectEvent ->) : Nil
      user_data.disconnect.remove_listener(listener)
    end
  end
end
