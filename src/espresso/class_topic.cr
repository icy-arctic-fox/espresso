require "./topic"

module Espresso
  # Base topic for all class event types.
  # Tracks subscribers and publishes notifications when an event occurs.
  # Operates as a proxy between GLFW bindings and Espresso types.
  private abstract struct ClassTopic(EventType) < Topic(EventType)
    # Subscribes a listener to the topic.
    def add_listener(listener : EventType ->) : Nil
      @listeners << listener
      register_callback if @listeners.size == 1 # Register on first listener.
    end

    # Unsubscribes a listener from the topic.
    def remove_listener(listener : EventType ->) : Bool
      @listeners.delete(listener).tap do
        # Unregister if there are no listeners left.
        unregister_callback if @listeners.empty?
      end
    end

    # Calls the GLFW binding to set up a static callback for the topic.
    private abstract def register_callback

    # Calls the GLFW binding to remove a static callback for the topic.
    private abstract def unregister_callback
  end
end
