module Espresso
  struct Window
    # Defines a getter method for a window attribute.
    # The *decl* is a type declaration in the form `name : Type`.
    # The type for *decl* should be `Bool`, `Int`, or an enum.
    # The method is named by the name specified in *decl*.
    # By default, the attribute will use the name as a symbol.
    # A value can be given in *decl* to manually specify an enum value from `LibGLFW::WindowAttribute`.
    private macro attribute_getter(decl)
      {% name = decl.var
         type = decl.type.resolve
         meth = type >= Bool ? "#{name}?".id : name
         attr = (decl.value || decl.var.id.symbolize) %}

      def {{meth}} : {{type}}
        value = expect_truthy { LibGLFW.get_window_attrib(@pointer, {{attr}}) }
        {% if type >= Bool %}
          !value.zero?
        {% else %}
          {{type}}.new(value)
        {% end %}
      end
    end

    # Defines a setter method for a window attribute.
    # The *decl* is a type declaration in the form `name : Type`.
    # The type for *decl* should be `Bool`, `Int`, or an enum.
    # It can also be nillable, which indicates GLFW accepts "don't care."
    # The method is named by the name specified in *decl*.
    # By default, the attribute will use the name as a symbol.
    # A value can be given in *decl* to manually specify an enum value from `LibGLFW::WindowAttribute`.
    private macro attribute_setter(decl)
      {% name = decl.var
         type = decl.type.resolve
         attr = (decl.value || decl.var.id.symbolize) %}

      def {{name}}=({{name}} : {{type}})
        {% if type >= Bool %}
          value = LibGLFW::Bool.new({{name}})
        {% else %}
          value = {{name}} || LibGLFW::DONT_CARE
        {% end %}
        checked { LibGLFW.set_window_attrib(@pointer, {{attr}}, value.to_i32) }
        {{name}}
      end
    end


    # Indicates whether this window has input focus.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter focused : Bool

    # Indicates whether this window is iconified (minimized).
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter iconified : Bool

    # Indicates whether this window is iconified (minimized).
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def minimized?
      iconified?
    end

    # Indicates whether this window is maximized.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter maximized : Bool

    # Indicates whether the cursor is currently directly over the content area of the window,
    # with no other windows between.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter hovered : Bool

    # Indicates whether this window is visible.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter visible : Bool

    # Indicates whether this window is resizable by the user.
    # This can be set before creation with the `WindowBuilder#resizable=` window hint
    # or after with `#resizable=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter resizable : Bool

    # Indicates whether this window has decorations
    # such as a border, a close widget, etc.
    # This can be set before creation with the `WindowBuilder#decorated=` window hint
    # or after with `#decorated=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter decorated : Bool

    # Indicates whether this window, when full screen, is iconified on focus loss,
    # a close widget, etc.
    # This can be set before creation with the `WindowBuilder#auto_iconify=` window hint
    # or after with `#auto_iconify=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter auto_iconify : Bool

    # Indicates whether this window is floating,
    # also called topmost or always-on-top.
    # This can be set before creation with the `WindowBuilder#floating=` window hint
    # or after with `#floating=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter floating : Bool

    # Indicates whether this window has a transparent framebuffer,
    # i.e. the window contents is composited with the background
    # using the window framebuffer alpha channel.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter transparent_framebuffer : Bool

    # Specifies whether the window will be given input focus when `#show` is called.
    # This can be set before creation with the `WindowBuilder#focus_on_show=` window hint
    # or after with `#focus_on_show=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter focus_on_show : Bool

    # Indicates the client API provided by the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter client_api : ClientAPI = LibGLFW::WindowAttribute::ClientAPI

    # Indicates the context creation API used to create the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter context_creation_api : ContextCreationAPI

    # Indicates the client API's major version number of the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter context_version_major : Int32

    # Indicates the client API's minor version number of the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter context_version_minor : Int32

    # Indicates the client API's revision number of the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter context_revision : Int32

    # Indicates the client API's complete version of the window's context.
    # Combines `#context_version_major`, `#context_version_minor`, and `#context_revision`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def context_version : SemanticVersion
      SemanticVersion.new(context_version_major, context_version_minor, context_version_revision)
    end

    # Indicates whether the window's context is an OpenGL forward-compatible one.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter forward_compatible : Bool = LibGLFW::WindowAttribute::OpenGLForwardCompat

    # Indicates whether the window's context is an OpenGL debug context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter debug : Bool = LibGLFW::WindowAttribute::OpenGLDebugContext

    # Indicates the OpenGL profile used by the context.
    # This is `OpenGLProfile::Core` or `OpenGLProfile::Compat` if the context uses a known profile,
    # or `OpenGLProfile::Any` if the OpenGL profile is unknown or the context is an OpenGL ES context.
    # Note that the returned profile may not match the profile bits of the context flags,
    # as GLFW will try other means of detecting the profile when no bits are set.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter profile : OpenGLProfile = LibGLFW::WindowAttribute::OpenGLProfile

    # Indicates the robustness strategy used by the context.
    # This is `ContextRobustness::LoseContextOnReset` or `ContextRobustness::NoResetNotification`
    # if the window's context supports robustness,
    # or `ContextRobustness::None` otherwise.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    attribute_getter robustness : ContextRobustness = LibGLFW::WindowAttribute::ContextRobustness

    # Updates whether the windowed mode window has decorations such as a border, a close widget, etc.
    # An undecorated window will not be resizable by the user
    # but will still allow the user to generate close events on some platforms.
    # Possible values are true and false.
    # This attribute is ignored for full screen windows.
    # The new value will take effect if the window is later made windowed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # Calling `#decorated?` will always return the latest value,
    # even if that value is ignored by the current mode of the window.
    attribute_setter decorated : Bool

    # Updates whether the windowed mode window will be resizable by the user.
    # The window will still be resizable using the `#resize` and related `#size=` methods.
    # Possible values are true and false.
    # This attribute is ignored for full screen windows and undecorated windows.
    # The new value will take effect if the window is later made windowed and is decorated.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # Calling `#resizable?` will always return the latest value,
    # even if that value is ignored by the current mode of the window.
    attribute_setter resizable : Bool

    # Updates whether the windowed mode window will be floating above other regular windows,
    # also called topmost or always-on-top.
    # This is intended primarily for debugging purposes
    # and cannot be used to implement proper full screen windows.
    # Possible values are true and false.
    # This attribute is ignored for full screen windows.
    # The new value will take effect if the window is later made windowed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # Calling `#floating?` will always return the latest value,
    # even if that value is ignored by the current mode of the window.
    attribute_setter floating : Bool

    # Updates whether the full screen window will automatically iconify (minimize)
    # and restore the previous video mode on input focus loss.
    # Possible values are true and false.
    # This attribute is ignored for windowed mode windows.
    # The new value will take effect if the window is later made full screen.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # Calling `#auto_iconify?` will always return the latest value,
    # even if that value is ignored by the current mode of the window.
    attribute_setter auto_iconify : Bool

    # Updates whether the window will be given input focus when `#show` is called.
    # Possible values are true and false.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # Calling `#focus_on_show?` will always return the latest value,
    # even if that value is ignored by the current mode of the window.
    attribute_setter focus_on_show : Bool
  end
end
