require "./topic"

module Espresso
  # Base topic for all instance event types.
  # Tracks subscribers and publishes notifications when an event occurs.
  # Operates as a proxy between GLFW bindings and Espresso types.
  private abstract struct InstanceTopic(EventType) < Topic(EventType)
    # Subscribes a listener to the topic.
    # *instance* is the object to dettach the listener to.
    def add_listener(instance, listener : EventType ->) : Nil
      @listeners << listener
      register_callback(instance) if @listeners.size == 1 # Register on first listener.
    end

    # Unsubscribes a listener from the topic.
    # *instance* is the object to attach the listener to.
    def remove_listener(instance, listener : EventType ->) : Bool
      @listeners.delete(listener).tap do
        # Unregister if there are no listeners left.
        unregister_callback(instance) if @listeners.empty?
      end
    end

    # Calls the GLFW binding to set up a static callback for the topic.
    # *instance* is the object to associate the callback with.
    private abstract def register_callback(instance)

    # Calls the GLFW binding to remove a static callback for the topic.
    # *instance* is the object to disassociate the callback with.
    private abstract def unregister_callback(instance)
  end
end
