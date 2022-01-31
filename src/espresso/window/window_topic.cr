module Espresso
  module WindowTopic
    private macro window_topic(func, decl)
      {% name = decl.var
         type = decl.type.resolve %}

      private struct {{name.camelcase}}Topic < InstanceTopic({{type}})
        include ErrorHandling

        private def register_callback(window)
          checked { LibGLFW.{{func.id}}(window, ->{{name.camelcase}}Topic.call) }
        end

        private def unregister_callback(window)
          checked { LibGLFW.{{func.id}}(window, nil) }
        end

        # Method called by GLFW when an event for this topic is invoked.
        protected def self.call(*args)
          window = args[0]
          pointer = expect_truthy { LibGLFW.get_window_user_pointer(window) }
          return unless pointer # No user data, no listeners.

          user_data = Box(WindowUserData).unbox(pointer)
          user_data.{{name}}.call { {{type}}.new(*args) }
        end
      end
    end

    private macro window_event(prop, decl)
      {% name = decl.var
         type = decl.type.resolve %}

      def on_{{name}}(&block : {{type}} ->)
        user_data.{{prop.id}}.add_listener(self, block)
        block
      end

      # Removes a previously registered listener added with `#on_{{name}}`.
      # The *proc* argument should be the return value of the `#on_{{name}}` method.
      def remove_{{name}}_listener(listener : {{type}} ->) : Nil
        user_data.{{prop.id}}.remove_listener(self, listener)
      end
    end
  end
end
