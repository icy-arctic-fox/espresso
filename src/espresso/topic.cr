module Espresso
  # Base topic for all event types.
  # Tracks subscribers and publishes notifications when an event occurs.
  # Operates as a proxy between GLFW bindings and Espresso types.
  private abstract struct Topic(EventType)
    # Subscribers of the topic.
    private getter listeners = [] of EventType ->

    # Subscribes a listener to the topic.
    # Additional arguments required for the GLFW bindings can be passed with *args*.
    def add_listener(listener : EventType ->, *args) : Nil
      @listeners << listener
      register_callback(*args) if @listeners.size == 1 # Register on first listener.
    end

    # Unsubscribes a listener from the topic.
    # Additional arguments required for the GLFW bindings can be passed with *args*.
    def remove_listener(listener : EventType ->, *args) : Bool
      @listeners.delete(listener).tap do
        # Unregister if there are no listeners left.
        unregister_callback(*args) if @listeners.empty?
      end
    end

    # Notifies subscribers than an event has occurred.
    # A block must be provided that constructs the event.
    protected def call : Nil
      return if @listeners.empty?

      event = yield
      @listeners.each &.call(event)
    end

    # Calls the GLFW binding to set up a static callback for the topic.
    # *args* contains arguments passed along from `#add_listener`.
    private abstract def register_callback(*args)

    # Calls the GLFW binding to remove a static callback for the topic.
    # *args* contains arguments passed along from `#remove_listener`.
    private abstract def unregister_callback(*args)
  end
end
