module Espresso
  # Data stored alongside an instance.
  #
  # Used to store event listeners and pass-through a user pointer.
  private abstract class UserData
    # Pins all user data instances in static memory to prevent garbage collection.
    protected class_getter instances = [] of self

    # Creates user data.
    # Adds the user data to the pinned instances.
    def initialize
      self.class.instances << self
    end

    # Custom data the end-user can attach to a window instance.
    property pointer : Void* = Pointer(Void).null
  end
end
