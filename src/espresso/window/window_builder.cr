require "../client_api"
require "../context_creation_api"
require "../context_robustness"
require "../error_handling"
require "../opengl_profile"
require "../release_behavior"
require "../window"

module Espresso
  # Simplifies creation of windows with the numerous options (hints) available.
  class WindowBuilder
    include ErrorHandling

    # Information about an integer-based hint.
    private struct Hint
      include ErrorHandling

      # Creates the hint.
      # The *hint* is the window hint to set,
      # and *value* is the desired value when the window is created.
      def initialize(@hint : LibGLFW::WindowHint, @value : Int32)
      end

      # Applies the hint to GLFW.
      def apply
        checked { LibGLFW.window_hint(@hint, @value) }
      end
    end

    # Information about a string-based hint.
    private struct StringHint
      include ErrorHandling

      # Creates the hint.
      # The *hint* is the window hint to set,
      # and *value* is the desired value when the window is created.
      def initialize(@hint : LibGLFW::WindowHint, @value : String)
      end

      # Applies the hint to GLFW.
      def apply
        checked { LibGLFW.window_hint_string(@hint, @value) }
      end
    end

    @hints = [] of Hint
    @string_hints = [] of StringHint

    # Defines one or more methods that set a hint.
    # The *decl* is a type declaration in the form `name : Type`.
    # The type for *decl* should be `Bool`, `Int`, `String`, or an enum.
    # It can also be nillable, which indicates GLFW accepts "don't care."
    # The methods are named by the name specified in *decl*.
    # By default, the hint will use the name as a symbol.
    # A value can be given in *decl* to manually specify an enum value from `LibGLFW::WindowHint`.
    private macro def_hint(decl)
      {% name = decl.var
         type = decl.type.resolve
         hint = (decl.value || decl.var.id.symbolize) %}

      def {{name}}=({{name}} : {{type}})
        {% if type >= Bool %}
          value = LibGLFW::Bool.new({{name}})
          @hints << Hint.new({{hint}}, value)
        {% elsif type >= String %}
          @string_hints << StringHint.new({{hint}}, {{name}})
        {% else %}
          @hints << Hint.new({{hint}}, {{name}}.to_i32)
        {% end %}
        {{name}}
      end

      {% if type >= Nil %}
        def {{name}}=({{name}} : Nil)
          @hints << Hint.new({{hint}}, LibGLFW::DONT_CARE)
          {{name}}
        end
      {% end %}

      {% if type >= Bool %}
        def {{name}} : self
          self.{{name}} = true
          self
        end
      {% end %}
    end

    # Creates the window with all previously specified hints.
    #
    # The *width* argument is the desired width, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *height* argument is the desired height, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *title* is the initial, UTF-8 encoded window title.
    # The *share* argument is the window whose context to share resources with.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def build(width : Int32, height : Int32, title : String, share : Window? = nil) : Window
      apply_hints { Window.new(width, height, title, share) }
    end

    # Creates the window with all previously specified hints.
    # The window is yielded to the block and automatically destroyed when the block completes.
    # Additionally, the window's context is made current on the calling thread.
    #
    # The *width* argument is the desired width, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *height* argument is the desired height, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *title* is the initial, UTF-8 encoded window title.
    # The *share* argument is the window whose context to share resources with.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def build(width : Int32, height : Int32, title : String, share : Window? = nil, & : Window -> _)
      build(width, height, title, share).tap do |window|
        window.current!
        yield window
      ensure
        window.destroy!
      end
    end

    # Creates the window as full screen with all previously specified hints.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    # The *width* and *height* specify the desired size of the window on the monitor.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def build_full_screen(title : String, monitor : Monitor = Monitor.primary, share : Window? = nil) : Window
      apply_hints { Window.full_screen(title, monitor, share) }
    end

    # Creates the window as full screen with all previously specified hints.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    # The *width* and *height* specify the desired size of the window on the monitor.
    # The *share* argument is the window whose context to share resources with.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def build_full_screen(title : String, width : Int32, height : Int32,
                          monitor : Monitor = Monitor.primary, share : Window? = nil) : Window
      apply_hints { Window.full_screen(title, width, height, monitor, share) }
    end

    # Creates the window as full screen with all previously specified hints.
    # The window is yielded to the block and automatically destroyed when the block completes.
    # Additionally, the window's context is made current on the calling thread.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    # The *share* argument is the window whose context to share resources with.
    #
    # The width and height of the window match the size of the monitor's current display mode.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def build_full_screen(title : String, monitor : Monitor = Monitor.primary, share : Window? = nil, & : Window -> _)
      build_full_screen(title, monitor, share).tap do |window|
        window.current!
        yield window
      ensure
        window.destroy!
      end
    end

    # Creates the window as full screen with all previously specified hints.
    # The window is yielded to the block and automatically destroyed when the block completes.
    # Additionally, the window's context is made current on the calling thread.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    # The *width* and *height* specify the desired size of the window on the monitor.
    # The *share* argument is the window whose context to share resources with.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def build_full_screen(title : String, width : Int32, height : Int32,
                          monitor : Monitor = Monitor.primary, share : Window? = nil, & : Window -> _)
      build_full_screen(title, width, height, monitor, share).tap do |window|
        window.current!
        yield window
      ensure
        window.destroy!
      end
    end

    # Applies all hints and then ensures they are reverted after calling the block.
    # The return value is the value returned by the block.
    private def apply_hints
      # Reset hints to their defaults.
      # Then apply all of the specified hints.
      reset_hints
      @hints.each(&.apply)
      @string_hints.each(&.apply)

      yield
    ensure
      reset_hints
    end

    # Resets all window hints to their defaults.
    private def reset_hints
      checked { LibGLFW.default_window_hints }
    end

    # Specifies whether the windowed mode window will be resizable *by the user*.
    # The window will still be resizable using the `Window.size=` setter.
    # Possible values are true and false.
    # This hint is ignored for full screen and undecorated windows.
    def_hint resizable : Bool

    # Specifies whether the windowed mode window will be initially visible.
    # Possible values are true and false.
    # This hint is ignored for full screen windows.
    def_hint visible : Bool

    # Specifies whether the windowed mode window will have window decorations
    # such as a border, a close widget, etc.
    # An undecorated window will not be resizable by the user,
    # but will still allow the user to generate close events on some platforms.
    # Possible values are true and false.
    # This hint is ignored for full screen windows.
    def_hint decorated : Bool

    # Specifies whether the windowed mode window will be given input focus when created.
    # Possible values are true and false.
    # This hint is ignored for full screen and initially hidden windows.
    def_hint focused : Bool

    # Specifies whether the full screen window will automatically iconify and restore
    # the previous video mode on input focus loss.
    # Possible values are true and false.
    # This hint is ignored for windowed mode windows.
    def_hint auto_iconify : Bool

    # Specifies whether the windowed mode window will be floating above other regular windows,
    # also called topmost or always-on-top.
    # This is intended primarily for debugging purposes and cannot be used to implement proper full screen windows.
    # Possible values are true and false.
    # This hint is ignored for full screen windows.
    def_hint floating : Bool

    # Specifies whether the windowed mode window will be maximized when created.
    # Possible values are true and false.
    # This hint is ignored for full screen windows.
    def_hint maximized : Bool

    # Specifies whether the cursor should be centered over newly created full screen windows.
    # Possible values are true and false.
    # This hint is ignored for windowed mode windows.
    def_hint center_cursor : Bool

    # Specifies whether the window framebuffer will be transparent.
    # If enabled and supported by the system,
    # the window framebuffer alpha channel will be used to combine the framebuffer with the background.
    # This does not affect window decorations.
    # Possible values are true and false.
    def_hint transparent_framebuffer : Bool

    # Specifies whether the window will be given input focus when `Window#show` is called.
    # Possible values are true and false.
    def_hint focus_on_show : Bool

    # Specifies whether the window content area should be resized
    # based on the monitor content scale of any monitor it is placed on.
    # This includes the initial placement when the window is created.
    # Possible values are true and false.
    #
    # This hint only has an effect on platforms
    # where screen coordinates and pixels always map 1:1 such as Windows and X11.
    # On platforms like macOS the resolution of the framebuffer is changed independently of the window size.
    def_hint scale_to_monitor : Bool

    # Specifies the desired bit depth of the red color component for the default framebuffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    def_hint red_bits : Int?

    # Specifies the desired bit depth of the green color component for the default framebuffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    def_hint green_bits : Int?

    # Specifies the desired bit depth of the blue color component for the default framebuffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    def_hint blue_bits : Int?

    # Specifies the desired bit depth of the alpha color component for the default framebuffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    def_hint alpha_bits : Int?

    # Specifies the desired bits used for the depth buffer of the default framebuffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    def_hint depth_bits : Int?

    # Specifies the desired bits used for the stencil buffer of the default framebuffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    def_hint stencil_bits : Int?

    # Specifies the desired bit depths of the red component of the accumulation buffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    #
    # Accumulation buffers are a legacy OpenGL feature and should not be used in new code.
    def_hint accum_red_bits : Int?

    # Specifies the desired bit depths of the green component of the accumulation buffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    #
    # Accumulation buffers are a legacy OpenGL feature and should not be used in new code.
    def_hint accum_green_bits : Int?

    # Specifies the desired bit depths of the blue component of the accumulation buffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    #
    # Accumulation buffers are a legacy OpenGL feature and should not be used in new code.
    def_hint accum_blue_bits : Int?

    # Specifies the desired bit depths of the alpha component of the accumulation buffer.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    #
    # Accumulation buffers are a legacy OpenGL feature and should not be used in new code.
    def_hint accum_alpha_bits : Int?

    # Specifies the desired number of auxiliary buffers.
    # Possible values are non-negative integers and nil.
    # Providing nil means the application has no preference (don't care).
    #
    # Auxiliary buffers are a legacy OpenGL feature and should not be used in new code.
    def_hint aux_buffers : Int?

    # Specifies whether to use OpenGL stereoscopic rendering.
    # Possible values are true and false.
    # This is a hard constraint.
    def_hint stereo : Bool

    # Specifies the desired number of samples to use for multisampling.
    # Zero disables multisampling.
    # A value of nil means the application has no preference (don't care).
    def_hint samples : Int?

    # Specifies whether the framebuffer should be sRGB capable.
    # Possible values are true and false.
    #
    # **OpenGL:** If enabled and supported by the system,
    # the `GL_FRAMEBUFFER_SRGB` enable will control sRGB rendering.
    # By default, sRGB rendering will be disabled.
    #
    # **OpenGL ES:** If enabled and supported by the system,
    # the context will always have sRGB rendering enabled.
    def_hint srgb_capable : Bool = LibGLFW::WindowHint::SRGBCapable

    # Specifies whether the framebuffer should be double buffered.
    # You nearly always want to use double buffering.
    # This is a hard constraint.
    # Possible values are true and false.
    def_hint double_buffer : Bool

    # Specifies the desired refresh rate for full screen windows.
    # A value of nil means the highest available refresh rate will be used.
    # This hint is ignored for windowed mode windows.
    def_hint refresh_rate : Int?

    # Specifies which client API to create the context for.
    # Possible values are in the `ClientAPI` enum.
    # This is a hard constraint.
    def_hint client_api : ClientAPI

    # Specifies which context creation API to use to create the context.
    # Possible values are in the `ContextCreationAPI` enum.
    # This is a hard constraint.
    # If no client API is requested (via `#client_api`), this hint is ignored.
    #
    # **macOS:** The EGL API is not available on this platform and requests to use it will fail.
    #
    # **Wayland:** The EGL API is the native context creation API, so this hint will have no effect.
    #
    # **OSMesa:** As its name implies, an OpenGL context created with OSMesa
    # does not update the window contents when its buffers are swapped.
    # Use OpenGL functions or the OSMesa native access functions `glfwGetOSMesaColorBuffer`
    # and `glfwGetOSMesaDepthBuffer` to retrieve the framebuffer contents.
    def_hint context_creation_api : ContextCreationAPI

    # Specifies the client API version that the created context must be compatible with.
    # The exact behavior of these hints depend on the request client API.
    #
    # **OpenGL:** These hints are not hard constraints,
    # but creation will fail if the OpenGL version of the created context is less than the one requested.
    # It is therefore perfectly safe to use the default of version 1.0 for legacy code
    # and you will still get backwards-compatible contexts of version 3.0 and above when available.
    #
    # While there is no way to ask the driver for a context of the highest supported version,
    # GLFW will attempt to provide this when you ask for a version 1.0 context,
    # which is the default for these hints.
    #
    # **OpenGL ES:** These hints are not hard constraints,
    # but creation will fail if the OpenGL ES version of the created context is less than the one requested.
    # Additionally, OpenGL ES 1.x cannot be returned if 2.0 or later was requested, and vice versa.
    # This is because OpenGL ES 3.x is backward compatible with 2.0,
    # but OpenGL ES 2.0 is not backward compatible with 1.x.
    def context_version(major : Int, minor : Int) : Nil
      @hints << Hint.new(:context_version_major, major.to_i32)
      @hints << Hint.new(:context_version_minor, minor.to_i32)
    end

    # Specifies whether the OpenGL context should be forward-compatible,
    # i.e. one where all functionality deprecated in the requested version of OpenGL is removed.
    # This must only be used if the requested OpenGL version is 3.0 or above.
    # If OpenGL ES is requested, this hint is ignored.
    def_hint forward_compatible : Bool = LibGLFW::WindowHint::OpenGLForwardCompat

    # Specifies whether to create a debug OpenGL context,
    # which may have additional error and performance issue reporting functionality.
    # Possible values are true and false.
    # If OpenGL ES is requested, this hint is ignored.
    def_hint debug : Bool = LibGLFW::WindowHint::OpenGLDebugContext

    # Specifies which OpenGL profile to create the context for.
    # Possible values are in the `OpenGLProfile` enum.
    # If requesting an OpenGL version below 3.2,
    # `OpenGLProfile::Any` must be used.
    # If OpenGL ES is requested, this hint is ignored.
    def_hint profile : OpenGLProfile = LibGLFW::WindowHint::OpenGLProfile

    # Specifies the robustness strategy to be used by the context.
    # This can be one of values from the `ContextRobustness` enum.
    def_hint robustness : ContextRobustness = LibGLFW::WindowHint::ContextRobustness

    # Specifies the release behavior to be used by the context.
    # Possible values are in the `ReleaseBehavior` enum.
    def_hint release_behavior : ReleaseBehavior = LibGLFW::WindowHint::ContextReleaseBehavior

    # Specifies whether errors should be generated by the context.
    # Possible values are true and false.
    # If enabled, situations that would have generated errors instead cause undefined behavior.
    def_hint no_error : Bool = LibGLFW::WindowHint::ContextNoError

    # Specifies whether to use full resolution framebuffers on Retina displays.
    # Possible values are true and false.
    # This is applicable only on macOS platforms.
    def_hint cocoa_retina_framebuffer : Bool

    # Specifies the UTF-8 encoded name to use for autosaving the window frame,
    # or if empty disables frame autosaving for the window.
    # This is applicable only on macOS platforms.
    def_hint cocoa_frame_name : String

    # Specifies whether to in Automatic Graphics Switching,
    # i.e. to allow the system to choose the integrated GPU for the OpenGL context
    # and move it between GPUs if necessary or whether to force it to always run on the discrete GPU.
    # This only affects systems with both integrated and discrete GPUs.
    # Possible values are true and false.
    # This is applicable only on macOS platforms.
    #
    # Simpler programs and tools may want to enable this to save power,
    # while games and other applications performing advanced rendering will want to leave it disabled.
    #
    # A bundled application that wishes to participate in Automatic Graphics Switching
    # should also declare this in its `Info.plist`
    # by setting the `NSSupportsAutomaticGraphicsSwitching` key to true.
    def_hint cocoa_graphics_switching : Bool

    # Specifies the desired ASCII encoded class part the ICCCM `WM_CLASS` window property.
    # This is applicable only on X11 platforms.
    def_hint x11_class_name : String

    # Specifies the desired ASCII encoded instance part of the ICCCM `WM_CLASS` window property.
    # This is applicable only on X11 platforms.
    def_hint x11_instance_name : String
  end
end
