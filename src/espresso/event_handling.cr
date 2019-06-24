require "glfw"

module Espresso
  # Mix-in to provide a macro for defining evenets and callbacks.
  # Exposes a single macro named `#event`.
  # This module can only be used on types that:
  # 1. Use `LibGLFW::Window`.
  # 2. Have a member `@pointer` that is a `LibGLFW::Window`.
  # 3. Define events where the first argument is a `LibGLFW::Window`.
  # This covers most of the callbacks in GLFW.
  private module EventHandling
    # Creates methods necessary for setting callbacks for events.
    # There are two methods created that are publicly exposed -
    # one to register a listener, and the other to deregister.
    # The registration method is prefixed with `on_`.
    # The deregistration method is `remove_*_listener`.
    #
    # The *name* argument is used to name these methods.
    # The *event_type* is the type of instance to pass to listener.
    # It also must have an initializer with the same arguments (and types) as the GLFW callback.
    # Lastly, the *function* is the name of the GLFW function used to set the callback.
    # For instance: `set_window_close_callback`.
    #
    # The comment block will be applied to the `on_*` method.
    # The deregistration method's documentation will be generated.
    private macro event(name, event_type, function)
      @@{{name.id}}_listeners = {} of LibGLFW::Window => Array({{event_type.id}} ->)

      # Method that is called by GLFW when any the event occurs.
      # This must be static, because closures can't be passed to C.
      # This method notifies all listeners of the event.
      protected def self.{{name.id}}_callback(*args)
        # Lookup listeners and do nothing if there are none.
        # This method shouldn't be called in this case,
        # which means the listeners didn't get cleaned up properly.
        pointer = args.first
        return unless (listeners = @@{{name.id}}_listeners[pointer]?)

        # Create the event instance and call each listener.
        event = {{event_type}}.new(*args)
        listeners.each(&.call(event))
      end

      def on_{{name.id}}(&block : {{event_type.id}} ->)
        if (listeners = @@{{name.id}}_listeners[@pointer]?)
          # Existing listeners, add new one to the list.
          listeners << block
        else
          # No existing listeners, create new entry for the list.
          @@{{name.id}}_listeners[@pointer] = [block]

          # Set callback to start listening for events.
          LibGLFW.{{function.id}}(@pointer, ->{{@type}}.{{name.id}}_callback)
        end

        # Return block as proc so that it can be removed later (if needed).
        block
      end

      # Removes a previously registered listener that responded to the `#on_{{name.id}}` callback.
      # The *proc* argument should be the return value of the `#on_{{name.id}}` method.
      def remove_{{name.id}}_listener(proc : {{event_type.id}} ->) : Nil
        # Don't do anything if there's no listeners.
        return unless (listeners = @@{{name.id}}_listeners[@pointer]?)

        # Remove listener from list.
        listeners.delete(proc)
        return unless listeners.empty?

        # No listeners left at this point, clean up.
        @@{{name.id}}_listeners.delete(@pointer)
        LibGLFW.{{function.id}}(nil)
      end
    end
  end
end
