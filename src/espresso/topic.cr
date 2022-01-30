module Espresso
  # Base topic for all event types.
  # Tracks subscribers and publishes notifications when an event occurs.
  # Operates as a proxy between GLFW bindings and Espresso types.
  private abstract struct Topic(EventType)
    # Subscribers of the topic.
    private getter listeners = [] of EventType ->

    # Notifies subscribers than an event has occurred.
    protected def call(event : EventType) : Nil
      @listeners.each &.call(event)
    end

    # Notifies subscribers than an event has occurred.
    # A block must be provided that constructs the event.
    protected def call(& : -> EventType) : Nil
      return if @listeners.empty?

      event = yield
      @listeners.each &.call(event)
    end
  end
end
