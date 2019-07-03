require "glfw"
require "semantic_version"
require "./bool_conversion"
require "./bounds"
require "./error_handling"
require "./event_handling"
require "./frame_size"
require "./keyboard"
require "./monitor"
require "./mouse"
require "./position"
require "./scale"
require "./size"

module Espresso
  # Encapsulates both a window and a context.
  # Windows can be created with the `#initialize` and `#full_screen` methods.
  # As the window and context are inseparably linked,
  # the underlying object pointer is used as both a context and window handle.
  #
  # Most of the options controlling how the window and its context
  # should be created are specified with window hints.
  #
  # Successful creation does not change which context is current.
  # Before you can use the newly created context, you need to make it current.
  #
  # The created window, framebuffer and context may differ from what you requested,
  # as not all parameters and hints are hard constraints.
  # This includes the size of the window, especially for full screen windows.
  # To query the actual attributes of the created window, framebuffer and context,
  # see `#size`, and `#framebuffer_size`.
  #
  # To create a full screen window, use the `#full_screen` method variants.
  # Unless you have a way for the user to choose a specific monitor,
  # it is recommended that you pick the primary monitor.
  #
  # For full screen windows,
  # the specified size becomes the resolution of the window's desired video mode.
  # As long as a full screen window is not iconified,
  # the supported video mode most closely matching the desired video mode is set for the specified monitor.
  #
  # Once you have created the window,
  # you can switch it between windowed and full screen mode with `#full_screen!` and `#windowed!`.
  # This will not affect its OpenGL or OpenGL ES context.
  #
  # By default, newly created windows use the placement recommended by the window system.
  # To create the window at a specific position,
  # make it initially invisible using the `WindowBuilder#visible=` setter,
  # set its position, and then show it.
  #
  # As long as at least one full screen window is not iconified,
  # the screensaver is prohibited from starting.
  #
  # Window systems put limits on window sizes.
  # Very large or very small window dimensions may be overridden by the window system on creation.
  # Check the actual size after creation.
  #
  # The swap interval is not set during window creation
  # and the initial value may vary depending on driver settings and defaults.
  #
  # **Windows:** Window creation will fail if the Microsoft GDI
  # software OpenGL implementation is the only one available.
  #
  # **Windows:** If the executable has an icon resource named GLFW_ICON,
  # it will be set as the initial icon for the window.
  # If no such icon is present, the IDI_APPLICATION icon will be used instead.
  # To set a different icon, see `#icon=`.
  #
  # **Windows:** The context to share resources with must not be current on any other thread.
  #
  # **macOS:** The OS only supports forward-compatible core profile contexts for OpenGL versions 3.2 and later.
  # Before creating an OpenGL context of version 3.2 or later
  # you must set the `WindowBuilder#opengl_forward_compat=` and `WindowBuilder#opengl_profile=` hints accordingly.
  # OpenGL 3.0 and 3.1 contexts are not supported at all on macOS.
  #
  # **macOS:** The GLFW window has no icon, as it is not a document window,
  # but the dock icon will be the same as the application bundle's icon.
  # For more information on bundles,
  # see the [Bundle Programming Guide](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/)
  # in the Mac Developer Library.
  #
  # **macOS:** The first time a window is created the menu bar is created.
  # If GLFW finds a `MainMenu.nib` it is loaded and assumed to contain a menu bar.
  # Otherwise a minimal menu bar is created manually with common commands like Hide, Quit and About.
  # The About entry opens a minimal about dialog with information from the application's bundle.
  # Menu bar creation can be disabled entirely with the *cocoa_menubar* flag in `Espresso#init`.
  #
  # **macOS:** On OS X 10.10 and later the window frame will not be rendered at full resolution on Retina displays
  # unless the `WindowBuilder#cocoa_retina_framebuffer=` hint is true and the `NSHighResolutionCapable` key
  # is enabled in the application bundle's `Info.plist`.
  # For more information,
  # see [High Resolution Guidelines](https://developer.apple.com/library/mac/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Explained/Explained.html)
  # for OS X in the Mac Developer Library.
  #
  # **macOS:** When activating frame autosaving with `WindowBuilder#cocoa_frame_name=`,
  # the specified window size and position may be overriden by previously saved values.
  #
  # **X11:** Some window managers will not respect the placement of initially hidden windows.
  #
  # **X11:** Due to the asynchronous nature of X11,
  # it may take a moment for a window to reach its requested state.
  # This means you may not be able to query the final size,
  # position, or other attributes directly after window creation.
  #
  # **X11:** The class part of the `WM_CLASS` window property
  # will by default be set to the window title passed to `#new` or `#full_screen`.
  # The instance part will use the contents of the `RESOURCE_NAME` environment variable,
  # if present and not empty, or fall back to the window title.
  # Set the `WindowBuilder#x11_class_name=` and `WindowBuilder#x11_instance_name=` window hints to override this.
  #
  # **Wayland:** Compositors should implement the xdg-decoration protocol
  # for GLFW to decorate the window properly.
  # If this protocol isn't supported, or if the compositor prefers client-side decorations,
  # a very simple fallback frame will be drawn using the wp_viewporter protocol.
  # A compositor can still emit close, maximize, or fullscreen events,
  # using for instance a keybind mechanism.
  # If neither of these protocols is supported, the window won't be decorated.
  #
  # **Wayland:** A full screen window will not attempt to change the mode,
  # no matter what the requested size or refresh rate.
  #
  # **Wayland:** Screensaver inhibition requires the idle-inhibit protocol
  # to be implemented in the user's compositor.
  struct Window
    include BoolConversion
    include ErrorHandling
    include EventHandling

    # Defines a getter method that retrieves the specified boolean attribute.
    # The *name* is the `LibGLFW::WindowAttribute` enum (without prefix) to get.
    # The getter method name is derived from *name*.
    private macro bool_attribute_getter(name)
      def {{name.id.gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
              .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
              .gsub(/_GL/, "GL").downcase}}?
        attribute = LibGLFW::WindowAttribute::{{name.id}}
        value = expect_truthy { LibGLFW.get_window_attrib(@pointer, attribute) }
        int_to_bool(value)
      end
    end

    # Defines a getter method that retrieves the specified integer attribute.
    # The *name* is the `LibGLFW::WindowAttribute` enum (without prefix) to get.
    # The getter method name is derived from *name*.
    private macro int_attribute_getter(name)
      def {{name.id.gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
              .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
              .gsub(/_GL/, "GL").downcase}}
        attribute = LibGLFW::WindowAttribute::{{name.id}}
        expect_truthy { LibGLFW.get_window_attrib(@pointer, attribute) }
      end
    end

    # Defines a getter method that retrieves the specified enum attribute.
    # The *name* is the `LibGLFW::WindowAttribute` enum (without prefix) to get.
    # The getter method name is derived from *name*.
    # The *enum_name* is the type name of the enum value that will be returned.
    private macro enum_attribute_getter(name, enum_name)
      def {{name.id.gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
              .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
              .gsub(/_GL/, "GL").downcase}} : {{enum_name.id}}
        attribute = LibGLFW::WindowAttribute::{{name.id}}
        value = expect_truthy { LibGLFW.get_window_attrib(@pointer, attribute) }
        {{enum_name.id}}.new(value)
      end
    end

    # Defines a setter method that updates the specified boolean attribute.
    # The *name* is the `LibGLFW::WindowAttribute` enum (without prefix) to set.
    # The setter method name is derived from *name*.
    private macro bool_attribute_setter(name)
      def {{name.id.gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
              .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
              .gsub(/_GL/, "GL").downcase}}=(flag)
        attribute = LibGLFW::WindowAttribute::{{name.id}}
        value = bool_to_int(flag)
        checked { LibGLFW.set_window_attrib(@pointer, attribute, value) }
      end
    end

    # Creates a window object by wrapping a GLFW window pointer.
    protected def initialize(@pointer : LibGLFW::Window)
    end

    # Creates a window and its associated OpenGL or OpenGL ES context.
    #
    # The *width* argument is the desired width, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *height* argument is the desired height, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *title* is the initial, UTF-8 encoded window title.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def initialize(width : Int32, height : Int32, title : String)
      @pointer = expect_truthy do
        LibGLFW.create_window(width, height, title, nil, nil)
      end
    end

    # Creates a window and its associated OpenGL or OpenGL ES context.
    #
    # The *width* argument is the desired width, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *height* argument is the desired height, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *title* is the initial, UTF-8 encoded window title.
    # The *share* argument is the window shose context to share resources with.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def initialize(width : Int32, height : Int32, title : String, share : Window)
      @pointer = expect_truthy do
        LibGLFW.create_window(width, height, title, nil, share)
      end
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    #
    # The primary monitor is used for the fullscreen window.
    # The width and height of the window match the size of the monitor's current display mode.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.full_screen(title : String)
      full_screen(title, Monitor.primary)
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    #
    # The width and height of the window match the size of the monitor's current display mode.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.full_screen(title : String, monitor : Monitor)
      size = monitor.size
      full_screen(title, monitor, size.width, size.height)
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
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
    def self.full_screen(title : String, monitor : Monitor, share : Window)
      size = monitor.size
      full_screen(title, monitor, width, height, share)
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    # The *width* and *height* specify the desired size of the window on the monitor.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.full_screen(title : String, monitor : Monitor, width : Int32, height : Int32)
      pointer = ErrorHandling.static_expect_truthy do
        LibGLFW.create_window(width, height, title, monitor, nil)
      end
      Window.new(pointer)
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    # The *width* and *height* specify the desired size of the window on the monitor.
    # The *share* argument is the window whose context to share resources with.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.full_screen(title : String, monitor : Monitor, width : Int32, height : Int32, share : Window)
      pointer = ErrorHandling.static_expect_truthy do
        LibGLFW.create_window(width, height, title, monitor, share)
      end
      Window.new(pointer)
    end

    # Destroys this window and its context.
    # On calling this method, no further callbacks will be called for this window.
    #
    # If the context of this window is current on the main thread,
    # it is detached before being destroyed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Do not** attempt to use the window after it has been destroyed.
    def destroy!
      remove_all_listeners
      checked { LibGLFW.destroy_window(@pointer) }
    end

    # Creates a window and its associated OpenGL or OpenGL ES context.
    # The window is yielded to the block and automatically destroyed when the block completes.
    # Additionally, the window's context is made current on the calling thread.
    #
    # The *width* argument is the desired width, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *height* argument is the desired height, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *title* is the initial, UTF-8 encoded window title.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.open(width : Int32, height : Int32, title : String)
      Window.new(width, height, title).tap do |window|
        window.current!
        yield window
      ensure
        window.destroy!
      end
    end

    # Creates a window and its associated OpenGL or OpenGL ES context.
    # The window is yielded to the block and automatically destroyed when the block completes.
    # Additionally, the window's context is made current on the calling thread.
    #
    # The *width* argument is the desired width, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *height* argument is the desired height, in screen coordinates, of the window.
    # This must be greater than zero.
    # The *title* is the initial, UTF-8 encoded window title.
    # The *share* argument is the window shose context to share resources with.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.open(width : Int32, height : Int32, title : String, share : Window)
      Window.new(width, height, title, share).tap do |window|
        window.current!
        yield window
      ensure
        window.destroy!
      end
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
    # The window is yielded to the block and automatically destroyed when the block completes.
    # Additionally, the window's context is made current on the calling thread.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    #
    # The primary monitor is used for the fullscreen window.
    # The width and height of the window match the size of the monitor's current display mode.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.full_screen(title : String, &block)
      full_screen(title, Monitor.primary, &block)
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
    # The window is yielded to the block and automatically destroyed when the block completes.
    # Additionally, the window's context is made current on the calling thread.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    #
    # The width and height of the window match the size of the monitor's current display mode.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.full_screen(title : String, monitor : Monitor, &block)
      size = monitor.size
      full_screen(title, monitor, size.width, size.height, &block)
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
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
    def self.full_screen(title : String, monitor : Monitor, share : Window, &block)
      size = monitor.size
      full_screen(title, monitor, width, height, share, &block)
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
    # The window is yielded to the block and automatically destroyed when the block completes.
    # Additionally, the window's context is made current on the calling thread.
    #
    # The *title* is the initial, UTF-8 encoded window title.
    # The *monitor* is the display device to place the fullscreen window on.
    # The *width* and *height* specify the desired size of the window on the monitor.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.full_screen(title : String, monitor : Monitor, width : Int32, height : Int32)
      Window.full_screen(title, monitor, width, height).tap do |window|
        window.current!
        yield window
      ensure
        window.destroy!
      end
    end

    # Creates a full screen window and its associated OpenGL or OpenGL ES context.
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
    def self.full_screen(title : String, monitor : Monitor, width : Int32, height : Int32, share : Window)
      Window.full_screen(title, monitor, width, height, share).tap do |window|
        window.current!
        yield window
      ensure
        window.destroy!
      end
    end

    # Registers a listener to respond when the window is moved.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowMoveEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_move_listener` with the proc returned by this method.
    #
    # **Wayland:** This callback will never be called,
    # as there is no way for an application to know its global position.
    event move, WindowMoveEvent, set_window_pos_callback

    # Registers a listener to respond when the window's size changes.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowResizeEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_resize_listener` with the proc returned by this method.
    event resize, WindowResizeEvent, set_window_size_callback

    # Registers a listener to respond when the user requests the window to be closed.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowClosingEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_closing_listener` with the proc returned by this method.
    #
    # The `#closing?` flag is set before this callback is called,
    # but you can modify it at any time with `#closing=`.
    #
    # **macOS:** Selecting Quit from the application menu will trigger the close callback for all windows.
    event closing, WindowClosingEvent, set_window_close_callback

    # Registers a listener to respond when the window's contents need to be redrawn,
    # for example if the window has been exposed after having been covered by another window.
    #
    # On compositing window systems such as Aero, Compiz, Aqua or Wayland,
    # where the window contents are saved off-screen,
    # this callback may be called only very infrequently or never at all.
    #
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowRefreshEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_refresh_listener` with the proc returned by this method.
    event refresh, WindowRefreshEvent, set_window_refresh_callback

    # Registers a listener to respond when the window gains or loses focus.
    #
    # After the focus callback is called for a window that lost input focus,
    # synthetic key and mouse button release events will be generated for all such that had been pressed.
    # For more information, see `glfwSetKeyCallback` and `glfwSetMouseButtonCallback`.
    #
    # The block of code passed to this method will be invoked when the request occurs.
    # A `WindowFocusEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_focus_listener` with the proc returned by this method.
    event focus, WindowFocusEvent, set_window_focus_callback

    # Registers a listener to respond when the window is iconified (minimized) or restored from being iconified.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowIconifyEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_iconify_listener` with the proc returned by this method.
    event iconify, WindowIconifyEvent, set_window_iconify_callback

    # Registers a listener to respond when the window is maximized or restored from being maximized.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowMaximizeEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_maximize_listener` with the proc returned by this method.
    event maximize, WindowMaximizeEvent, set_window_maximize_callback

    # Registers a listener to respond when the window's framebuffer is resized.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowResizeEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_framebuffer_resize_listener` with the proc returned by this method.
    event framebuffer_resize, WindowResizeEvent, set_framebuffer_size_callback

    # Registers a listener to respond when the window's content scaling changes.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowScaleEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_scale_listener` with the proc returned by this method.
    event scale, WindowScaleEvent, set_window_content_scale_callback

    # Registers a listener to respond when when one or more dragged files are dropped on the window.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowDropEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_drop_listener` with the proc returned by this method.
    #
    # **Wayland:** File drop is currently unimplemented.
    event drop, WindowDropEvent, set_drop_callback

    # Registers a listener to respond when the window is iconified (minimized) or restored from being iconified.
    # The block of code passed to this method will be invoked when the event occurs.
    # A `WindowIconifyEvent` instance will be passed to the block as an argument,
    # which contains all relevant information about the event.
    # To remove the listener, call `#remove_iconify_listener` with the proc returned by this method.
    def on_minimize(&block : WindowIconifyEvent ->)
      on_iconify(&block)
    end

    # Removes a previously registered listener that responded to the `#on_minimize` callback.
    # The *proc* argument should be the return value of the `#on_minimize` method.
    def remove_minimize_listener(proc : WindowIconifyEvent ->) : Nil
      remove_iconify_listener(proc)
    end

    # Removes all previously registered listeners for all window events.
    private def remove_all_listeners
      clear_move_listeners
      clear_resize_listeners
      clear_closing_listeners
      clear_refresh_listeners
      clear_focus_listeners
      clear_iconify_listeners
      clear_maximize_listeners
      clear_framebuffer_resize_listeners
      clear_scale_listeners
      clear_drop_listeners
      mouse.remove_all_listeners
      keyboard.remove_all_listeners
    end

    # Retrieves the mouse instance for this window.
    # Even though the system may only have one logical mouse attached,
    # mouse instances are tied to a window.
    def mouse
      Mouse.new(@pointer)
    end

    # Retrieves the keyboard instance for this window.
    # Even though the system may only have one logical keyboard attached,
    # keyboard instances are tied to a window.
    def keyboard
      Keyboard.new(@pointer)
    end

    # Checks whether the window should be closed.
    #
    # See also: `#closing=`
    def closing?
      value = checked { LibGLFW.window_should_close(@pointer) }
      int_to_bool(value)
    end

    # Sets whether the window should be closed.
    # This can be used to override the user's attempt to close the window,
    # or to signal that it should be closed.
    #
    # See also: `#closing?`
    def closing=(flag)
      value = bool_to_int(flag)
      checked { LibGLFW.set_window_should_close(@pointer, value) }
    end

    # Updates the window's title.
    # The new *title* is specified as a UTF-8 encoded string.
    def title=(title)
      checked { LibGLFW.set_window_title(@pointer, title) }
    end

    def icon=(icon)
      raise NotImplementedError.new("Window#icon=")
    end

    # Retrieves the position, in screen coordinates, of the upper-left corner
    # of the content area of this window.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def position
      x = uninitialized Int32
      y = uninitialized Int32

      checked { LibGLFW.get_window_pos(@pointer, pointerof(x), pointerof(y)) }
      Position.new(x, y)
    end

    # Sets the position, in screen coordinates, of the upper-left corner
    # of the content area of this windowed mode window.
    # If the window is a full screen window, this function does nothing.
    #
    # **Do not use this method** to move an already visible window
    # unless you have very good reasons for doing so,
    # as it will confuse and annoy the user.
    #
    # The window manager may put limits on what positions are allowed.
    # GLFW cannot and should not override these limits.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def position=(position : Tuple(Int32, Int32))
      move(*position)
    end

    # Sets the position, in screen coordinates, of the upper-left corner
    # of the content area of this windowed mode window.
    # If the window is a full screen window, this function does nothing.
    #
    # **Do not use this method** to move an already visible window
    # unless you have very good reasons for doing so,
    # as it will confuse and annoy the user.
    #
    # The window manager may put limits on what positions are allowed.
    # GLFW cannot and should not override these limits.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def position=(position : NamedTuple(x: Int32, y: Int32))
      move(**position)
    end

    # Sets the position, in screen coordinates, of the upper-left corner
    # of the content area of this windowed mode window.
    # If the window is a full screen window, this function does nothing.
    #
    # **Do not use this method** to move an already visible window
    # unless you have very good reasons for doing so,
    # as it will confuse and annoy the user.
    #
    # The window manager may put limits on what positions are allowed.
    # GLFW cannot and should not override these limits.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def position=(position)
      move(position.x, position.y)
    end

    # Sets the position, in screen coordinates, of the upper-left corner
    # of the content area of this windowed mode window.
    # If the window is a full screen window, this function does nothing.
    #
    # **Do not use this method** to move an already visible window
    # unless you have very good reasons for doing so,
    # as it will confuse and annoy the user.
    #
    # The window manager may put limits on what positions are allowed.
    # GLFW cannot and should not override these limits.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def move(x, y)
      checked { LibGLFW.set_window_pos(@pointer, x, y) }
    end

    # Retrieves the size, in screen coordinates, of the content area of this window.
    # If you wish to retrieve the size of the framebuffer of the window in pixels, see `#framebuffer_size`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def size
      width = uninitialized Int32
      height = uninitialized Int32

      checked { LibGLFW.get_window_size(@pointer, pointerof(width), pointerof(height)) }
      Size.new(width, height)
    end

    # Sets the size, in screen coordinates, of the content area of this window.
    #
    # For full screen windows, this function updates the resolution
    # of its desired video mode and switches to the video mode closest to it,
    # without affecting the window's context.
    # As the context is unaffected, the bit depths of the framebuffer remain unchanged.
    #
    # If you wish to update the refresh rate of the desired video mode
    # in addition to its resolution, see `#full_screen`.
    #
    # The window manager may put limits on what sizes are allowed.
    # GLFW cannot and should not override these limits.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** A full screen window will not attempt to change the mode,
    # no matter what the requested size.
    def size=(size : Tuple(Int32, Int32))
      resize(*size)
    end

    # Sets the size, in screen coordinates, of the content area of this window.
    #
    # For full screen windows, this function updates the resolution
    # of its desired video mode and switches to the video mode closest to it,
    # without affecting the window's context.
    # As the context is unaffected, the bit depths of the framebuffer remain unchanged.
    #
    # If you wish to update the refresh rate of the desired video mode
    # in addition to its resolution, see `#full_screen`.
    #
    # The window manager may put limits on what sizes are allowed.
    # GLFW cannot and should not override these limits.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** A full screen window will not attempt to change the mode,
    # no matter what the requested size.
    def size=(size : NamedTuple(width: Int32, height: Int32))
      resize(**size)
    end

    # Sets the size, in screen coordinates, of the content area of this window.
    #
    # For full screen windows, this function updates the resolution
    # of its desired video mode and switches to the video mode closest to it,
    # without affecting the window's context.
    # As the context is unaffected, the bit depths of the framebuffer remain unchanged.
    #
    # If you wish to update the refresh rate of the desired video mode
    # in addition to its resolution, see `#full_screen`.
    #
    # The window manager may put limits on what sizes are allowed.
    # GLFW cannot and should not override these limits.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** A full screen window will not attempt to change the mode,
    # no matter what the requested size.
    def size=(size)
      resize(size.width, size.height)
    end

    # Sets the size, in screen coordinates, of the content area of this window.
    #
    # For full screen windows, this function updates the resolution
    # of its desired video mode and switches to the video mode closest to it,
    # without affecting the window's context.
    # As the context is unaffected, the bit depths of the framebuffer remain unchanged.
    #
    # If you wish to update the refresh rate of the desired video mode
    # in addition to its resolution, see `#full_screen`.
    #
    # The window manager may put limits on what sizes are allowed.
    # GLFW cannot and should not override these limits.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** A full screen window will not attempt to change the mode,
    # no matter what the requested size.
    def resize(width, height)
      checked { LibGLFW.set_window_size(@pointer, width, height) }
    end

    # Sets the size limits of the content area of this window.
    # If the window is full screen, the size limits only take effect once it is made windowed.
    # If the window is not resizable, this function does nothing.
    #
    # The size limits are applied immediately to a windowed mode window and may cause it to be resized.
    #
    # The maximum dimensions must be greater than or equal to the minimum dimensions
    # and all must be greater than or equal to zero.
    # Specify nil for an argument to leave it unbounded.
    #
    # Possible errors that could be raised are: `NotInitializedError`, `InvalidValueError`, and `PlatformError`.
    #
    # If you set size limits and an aspect ratio that conflict, the results are undefined.
    #
    # **Wayland:** The size limits will not be applied until the window is actually resized,
    # either by the user or by the compositor.
    def limit_size(min_width = nil, min_height = nil, max_width = nil, max_height = nil)
      min_width ||= LibGLFW::DONT_CARE
      min_height ||= LibGLFW::DONT_CARE
      max_width ||= LibGLFW::DONT_CARE
      max_height ||= LibGLFW::DONT_CARE
      checked { LibGLFW.set_window_size_limits(@pointer, min_width, min_height, max_width, max_height) }
    end

    # Unsets the size limits of the content area of this window.
    # If the window is full screen, the size limits only take effect once it is made windowed.
    # If the window is not resizable, this function does nothing.
    #
    # Possible errors that could be raised are: `NotInitializedError`, and `PlatformError`.
    #
    # **Wayland:** The size limits will not be applied until the window is actually resized,
    # either by the user or by the compositor.
    def unlimit_size
      checked do
        LibGLFW.set_window_size_limits(@pointer,
          LibGLFW::DONT_CARE, LibGLFW::DONT_CARE, LibGLFW::DONT_CARE, LibGLFW::DONT_CARE)
      end
    end

    # Sets the required aspect ratio of the content area of this window.
    # If the window is full screen, the aspect ratio only takes effect once it is made windowed.
    # If the window is not resizable, this function does nothing.
    #
    # The aspect ratio is specified as a *numerator* and a *denominator*
    # and both values must be greater than zero.
    # For example, the common 16:9 aspect ratio is specified as 16 and 9, respectively.
    #
    # The aspect ratio is applied immediately to a windowed mode window and may cause it to be resized.
    #
    # Possible errors that could be raised are: `NotInitializedError`, `InvalidValueError`, and `PlatformError`.
    #
    # If you set size limits and an aspect ratio that conflict, the results are undefined.
    #
    # **Wayland:** The aspect ratio will not be applied until the window is actually resized,
    # either by the user or by the compositor.
    def aspect_ratio(numerator, denominator)
      checked { LibGLFW.set_window_aspect_ratio(@pointer, numerator, denominator) }
    end

    # Disables the aspect ratio limit.
    # Allows the window to be resized without restricting to a given aspect ratio.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def disable_aspect_ratio
      aspect_ratio(LibGLFW::DONT_CARE, LibGLFW::DONT_CARE)
    end

    # Retrieves the size, in pixels, of the framebuffer of this window.
    # If you wish to retrieve the size of the window in screen coordinates, see `#size`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def framebuffer_size
      width = uninitialized Int32
      height = uninitialized Int32

      checked { LibGLFW.get_framebuffer_size(@pointer, pointerof(width), pointerof(height)) }
      Size.new(width, height)
    end

    # Retrieves the size, in screen coordinates, of each edge of the frame of this window.
    # This size includes the title bar, if the window has one.
    # The size of the frame may vary depending on the window-related hints used to create it.
    #
    # Because this method retrieves the size of each window frame edge
    # and not the offset along a particular coordinate axis,
    # the retrieved values will always be zero or positive.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def frame_size
      left = uninitialized Int32
      top = uninitialized Int32
      right = uninitialized Int32
      bottom = uninitialized Int32

      checked do
        LibGLFW.get_window_frame_size(@pointer,
          pointerof(left), pointerof(top), pointerof(right), pointerof(bottom))
      end
      FrameSize.new(left, top, right, bottom)
    end

    # Retrieves the content scale for this window.
    # The content scale is the ratio between the current DPI and the platform's default DPI.
    # This is especially important for text and any UI elements.
    # If the pixel dimensions of your UI scaled by this look appropriate on your machine
    # then it should appear at a reasonable size on other machines
    # regardless of their DPI and scaling settings.
    # This relies on the system DPI and scaling settings being somewhat correct.
    #
    # On systems where each monitors can have its own content scale,
    # the window content scale will depend on which monitor the system considers the window to be on.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def scale
      x = uninitialized Float32
      y = uninitialized Float32

      checked { LibGLFW.get_window_content_scale(@pointer, pointerof(x), pointerof(y)) }
      Scale.new(x, y)
    end

    # Returns the opacity of the window, including any decorations.
    #
    # The opacity (or alpha) value is a positive finite number between zero and one,
    # where zero is fully transparent and one is fully opaque.
    # If the system does not support whole window transparency, this function always returns one.
    #
    # The initial opacity value for newly created windows is one.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def opacity
      checked { LibGLFW.get_window_opacity(@pointer) }
    end

    # Sets the opacity of the window, including any decorations.
    #
    # The opacity (or alpha) value is a positive finite number between zero and one,
    # where zero is fully transparent and one is fully opaque.
    #
    # The initial opacity value for newly created windows is one.
    #
    # A window created with framebuffer transparency may not use whole window transparency.
    # The results of doing this are undefined.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def opacity=(opacity)
      checked { LibGLFW.set_window_opacity(@pointer, opacity) }
    end

    # Iconifies (minimizes) this window if it was previously restored.
    # If the window is already iconified, this function does nothing.
    #
    # If the specified window is a full screen window,
    # the original monitor resolution is restored until the window is restored.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** There is no concept of iconification in wl_shell,
    # this method will raise a `PlatformError` when using this deprecated protocol.
    def iconify
      checked { LibGLFW.iconify_window(@pointer) }
    end

    # Restores this window if it was previously iconified (minimized) or maximized.
    # If the window is already restored, this function does nothing.
    #
    # If the specified window is a full screen window,
    # the resolution chosen for the window is restored on the selected monitor.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def restore
      checked { LibGLFW.restore_window(@pointer) }
    end

    # Maximizes this window if it was previously not maximized.
    # If the window is already maximized, this function does nothing.
    #
    # If the specified window is a full screen window, this function does nothing.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def maximize
      checked { LibGLFW.maximize_window(@pointer) }
    end

    # Makes this window visible if it was previously hidden.
    # If the window is already visible or is in full screen mode, this function does nothing.
    #
    # By default, windowed mode windows are focused when shown.
    # Set the `WindowBuilder#focus_on_show=` hint to change this behavior,
    # or change the behavior for an existing window with `#focus_on_show=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def show
      checked { LibGLFW.show_window(@pointer) }
    end

    # Hides this window if it was previously visible.
    # If the window is already hidden or is in full screen mode, this function does nothing.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def hide
      checked { LibGLFW.hide_window(@pointer) }
    end

    # Brings this window to front and sets input focus.
    # The window should already be visible and not iconified.
    #
    # By default, both windowed and full screen mode windows are focused when initially created.
    # Set the `WindowBuilder#focused=` hint to disable this behavior.
    #
    # Also by default, windowed mode windows are focused when shown with `#show`.
    # Set the `WindowBuilder#focus_on_show=` hint to disable this behavior.
    #
    # **Do not use this function** to steal focus from other applications
    # unless you are certain that is what the user wants.
    # Focus stealing can be extremely disruptive.
    #
    # For a less disruptive way of getting the user's attention, see `#request_attention`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** It is not possible for an application to bring its windows to front,
    # this method will always raise a `PlatformError`.
    def focus
      checked { LibGLFW.focus_window(@pointer) }
    end

    # Requests user attention to this window.
    # On platforms where this is not supported,
    # attention is requested to the application as a whole.
    #
    # Once the user has given attention,
    # usually by focusing the window or application,
    # the system will end the request automatically.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **macOS:** Attention is requested to the application as a whole, not the specific window.
    def request_attention
      checked { LibGLFW.request_window_attention(@pointer) }
    end

    # Retrieves the contents of the system clipboard,
    # if it contains or is convertible to a UTF-8 encoded string.
    # If the clipboard is empty or if its contents cannot be converted,
    # a `FormatUnavailableError` is raised.
    #
    # Possible errors that could be raised are: `NotInitializedError`, `PlatformError`, and `FormatUnavailableError`.
    def clipboard
      chars = expect_truthy { LibGLFW.get_clipboard_string(@pointer) }
      String.new(chars)
    end

    # Sets the contents of the system clipboard,
    # to the specified UTF-8 encoded *string*.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def clipboard=(string)
      checked { LibGLFW.set_clipboard_string(@pointer, string) }
    end

    # Attempts to retrieve the monitor the full screen window is using.
    # If the window isn't full screen, then nil is returned.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    def monitor?
      pointer = expect_truthy { LibGLFW.get_monitor_window(@pointer) }
      pointer ? Monitor.new(pointer) : nil
    end

    # Retrieves the monitor the full screen window is using.
    # If the window isn't full screen, then an error is raised.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `NilAssertionError`.
    def monitor
      monitor?.not_nil!
    end

    # Sets the window to full screen mode on the specified monitor.
    # The window's size will be changed to the monitor's size.
    # The monitor's existing frame rate will be used.
    #
    # The OpenGL or OpenGL ES context will not be destroyed
    # or otherwise affected by any resizing or mode switching,
    # although you may need to update your viewport if the framebuffer size has changed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def monitor=(monitor)
      full_screen!(monitor)
    end

    # Makes the window full screen on the primary monitor.
    # The window's size will be changed to the monitor's size.
    # The monitor's existing frame rate will be used.
    #
    # The OpenGL or OpenGL ES context will not be destroyed
    # or otherwise affected by any resizing or mode switching,
    # although you may need to update your viewport if the framebuffer size has changed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def full_screen!
      full_screen!(Monitor.primary)
    end

    # Makes the window full screen on the specified monitor.
    # The window's size will be changed to the monitor's size.
    # The monitor's existing frame rate will be used.
    #
    # The OpenGL or OpenGL ES context will not be destroyed
    # or otherwise affected by any resizing or mode switching,
    # although you may need to update your viewport if the framebuffer size has changed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def full_screen!(monitor)
      size = monitor.size
      full_screen!(monitor, size.width, size.height)
    end

    # Makes the window full screen on the specified monitor.
    # The monitor and window's size will be changed to the dimensions given.
    # The monitor's existing frame rate will be used.
    #
    # The OpenGL or OpenGL ES context will not be destroyed
    # or otherwise affected by any resizing or mode switching,
    # although you may need to update your viewport if the framebuffer size has changed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** Setting the window to full screen will not attempt to change the mode,
    # no matter what the requested size or refresh rate.
    def full_screen!(monitor, width, height)
      checked { LibGLFW.set_window_monitor(@pointer, monitor, 0, 0, width, height, LibGLFW::DONT_CARE) }
    end

    # Makes the window full screen on the specified monitor.
    # The monitor and window's size will be changed to the dimensions given.
    #
    # The OpenGL or OpenGL ES context will not be destroyed
    # or otherwise affected by any resizing or mode switching,
    # although you may need to update your viewport if the framebuffer size has changed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** Setting the window to full screen will not attempt to change the mode,
    # no matter what the requested size or refresh rate.
    def full_screen!(monitor, width, height, refresh_rate)
      checked { LibGLFW.set_window_monitor(@pointer, monitor, 0, 0, width, height, refresh_rate) }
    end

    # Changes the window from full screen to windowed mode.
    # The window will be resized to the specified dimensions
    # and positioned at the given *x* and *y* coordinates.
    #
    # When a window transitions from full screen to windowed mode,
    # this method restores any previous window settings
    # such as whether it is decorated, floating, resizable, has size or aspect ratio limits, etc.
    #
    # The OpenGL or OpenGL ES context will not be destroyed
    # or otherwise affected by any resizing or mode switching,
    # although you may need to update your viewport if the framebuffer size has changed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Wayland:** The desired window position is ignored,
    # as there is no way for an application to set this property.
    def windowed!(x, y, width, height)
      checked { LibGLFW.set_window_monitor(@pointer, nil, x, y, width, height, LibGLFW::DONT_CARE) }
    end

    # Checks whether the window is currently in full screen mode.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    def full_screen?
      !windowed?
    end

    # Checks whether the window is currently in windowed mode.
    # In other words, it is *not* in full screen mode.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    def windowed?
      monitor?.nil?
    end

    # Retrieves the current value of the user-defined pointer for this window.
    # This can be used for any purpose you need and will not be modified by GLFW.
    # The value will be kept until the window is destroyed or until the library is terminated.
    # The initial value is nil.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    def user_pointer
      expect_truthy { LibGLFW.get_window_user_pointer(@pointer, pointer) }
    end

    # Updates the value of the user-defined pointer for this window.
    # This can be used for any purpose you need and will not be modified by GLFW.
    # The value will be kept until the window is destroyed or until the library is terminated.
    # The initial value is nil.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    def user_pointer=(pointer)
      checked { LibGLFW.set_window_user_pointer(@pointer, pointer) }
    end

    # Swaps the front and back buffers of this window
    # when rendering with OpenGL or OpenGL ES.
    # If the swap interval is greater than zero,
    # the GPU driver waits the specified number of screen updates before swapping the buffers.
    #
    # This window must have an OpenGL or OpenGL ES context.
    # Calling this on a window without a context will raise `NoWindowContextError`.
    #
    # This function does not apply to Vulkan.
    # If you are rendering with Vulkan, see `vkQueuePresentKHR` instead.
    #
    # Possible errors that could be raised are: `NotInitializedError`, `NoWindowContextError`, and `PlatformError`.
    #
    # **EGL:** The context of the specified window must be current on the calling thread.
    def swap_buffers
      checked { LibGLFW.swap_buffers(@pointer) }
    end

    # Indicates whether this window has input focus.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter Focused

    # Indicates whether this window is iconified (minimized).
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter Iconified

    # Indicates whether this window is maximized.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter Maximized

    # Indicates whether the cursor is currently directly over the content area of the window,
    # with no other windows between.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter Hovered

    # Indicates whether this window is visible.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter Visible

    # Indicates whether this window is resizable by the user.
    # This can be set before creation with the `WindowBuilder#resizable=` window hint
    # or after with `#resizable=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter Resizable

    # Indicates whether this window has decorations
    # such as a border, a close widget, etc.
    # This can be set before creation with the `WindowBuilder#decorated=` window hint
    # or after with `#decorated=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter Decorated

    # Indicates whether this window, when full screen, is iconified on focus loss,
    # a close widget, etc.
    # This can be set before creation with the `WindowBuilder#auto_iconify=` window hint
    # or after with `#auto_iconify=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter AutoIconify

    # Indicates whether this window is floating,
    # also called topmost or always-on-top.
    # This can be set before creation with the `WindowBuilder#floating=` window hint
    # or after with `#floating=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter Floating

    # Indicates whether this window has a transparent framebuffer,
    # i.e. the window contents is composited with the background
    # using the window framebuffer alpha channel.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter TransparentFramebuffer

    # Specifies whether the window will be given input focus when `#show` is called.
    # This can be set before creation with the `WindowBuilder#focus_on_show=` window hint
    # or after with `#focus_on_show=`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter FocusOnShow

    # Indicates the client API provided by the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    enum_attribute_getter ClientAPI, ClientAPI

    # Indicates the context creation API used to create the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    enum_attribute_getter ContextCreationAPI, ContextCreationAPI

    # Indicates the client API's major version number of the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    int_attribute_getter ContextVersionMajor

    # Indicates the client API's minor version number of the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    int_attribute_getter ContextVersionMinor

    # Indicates the client API's revision number of the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    int_attribute_getter ContextRevision

    # Indicates whether the window's context is an OpenGL forward-compatible one.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter OpenGLForwardCompat

    # Indicates whether the window's context is an OpenGL debug context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    bool_attribute_getter OpenGLDebugContext

    # Indicates the OpenGL profile used by the context.
    # This is `OpenGLProfile::Core` or `OpenGLProfile::Compat` if the context uses a known profile,
    # or `OpenGLProfile::Any` if the OpenGL profile is unknown or the context is an OpenGL ES context.
    # Note that the returned profile may not match the profile bits of the context flags,
    # as GLFW will try other means of detecting the profile when no bits are set.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    enum_attribute_getter OpenGLProfile, OpenGLProfile

    # Indicates the robustness strategy used by the context.
    # This is `ContextRobustness::LoseContextOnReset` or `ContextRobustness::NoResetNotification`
    # if the window's context supports robustness,
    # or `ContextRobustness::None` otherwise.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    enum_attribute_getter ContextRobustness, ContextRobustness

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
    bool_attribute_setter Decorated

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
    bool_attribute_setter Resizable

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
    bool_attribute_setter Floating

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
    bool_attribute_setter AutoIconify

    # Updates whether the window will be given input focus when `#show` is called.
    # Possible values are true and false.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # Calling `#focus_on_show?` will always return the latest value,
    # even if that value is ignored by the current mode of the window.
    bool_attribute_setter FocusOnShow

    # Indicates the client API's version of the window's context.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def context_version
      SemanticVersion.new(context_version_major, context_version_minor, context_revision)
    end

    # Indicates whether this window is iconified (minimized).
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def minimized?
      iconified?
    end

    # Makes the OpenGL or OpenGL ES context of this window current on the calling thread.
    # A context must only be made current on a single thread at a time
    # and each thread can have only a single current context at a time.
    #
    # When moving a context between threads,
    # you must make it non-current on the old thread before making it current on the new one.
    #
    # By default, making a context non-current implicitly forces a pipeline flush.
    # On machines that support `GL_KHR_context_flush_control`,
    # you can control whether a context performs this flush
    # by setting the `WindowBuilder#context_release_behavior=` hint.
    #
    # This window must have an OpenGL or OpenGL ES context.
    # Specifying a window without a context will generate a `NoWindowContextError` error.
    #
    # Possible errors that could be raised are: `NotInitializedError`, `NoWindowContextError`, and `PlatformError`.
    def current!
      checked { LibGLFW.make_context_current(@pointer) }
    end

    # Checks whether this window's OpenGL or OpenGL ES context is current on the calling thread.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    #
    # See also: `#current!`
    def current?
      @pointer == expect_truthy { LibGLFW.get_current_context }
    end

    # Returns the window whose OpenGL or OpenGL ES context is current on the calling thread.
    # This will return nil if no window's context is current.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    #
    # See also: `#current!`
    def self.current?
      pointer = ErrorHandling.static_expect_truthy { LibGLFW.get_current_context }
      pointer ? Window.new(pointer) : nil
    end

    # Returns the window whose OpenGL or OpenGL ES context is current on the calling thread.
    # This will raise a `NilAssertionError` if no window is current.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `NilAssertionError`.
    def self.current
      current?.not_nil!
    end

    # Returns the underlying GLFW window and context pointer.
    def to_unsafe
      @pointer
    end

    # Processes only those events that are already in the event queue and then returns immediately.
    # Processing events will cause the window and input callbacks associated with those events to be called.
    #
    # On some platforms, a window move, resize or menu operation will cause event processing to block.
    # This is due to how event processing is designed on those platforms.
    # You can use the window refresh callback to redraw the contents of your window
    # when necessary during such operations.
    #
    # Do not assume that callbacks you set will only be called
    # in response to event processing functions like this one.
    # While it is necessary to poll for events,
    # window systems that require GLFW to register callbacks of its own
    # can pass events to GLFW in response to many window system function calls.
    # GLFW will pass those events on to the application callbacks before returning.
    #
    # Event processing is not required for joystick input to work.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def self.poll_events
      ErrorHandling.static_checked { LibGLFW.poll_events }
    end

    # Puts the calling thread to sleep until at least one event is available in the event queue.
    # Once one or more events are available, it behaves exactly like `#poll_events`,
    # i.e. the events in the queue are processed and the function then returns immediately.
    # Processing events will cause the window and input callbacks associated with those events to be called.
    #
    # Since not all events are associated with callbacks,
    # this function may return without a callback having been called even if you are monitoring all callbacks.
    #
    # On some platforms, a window move, resize or menu operation will cause event processing to block.
    # This is due to how event processing is designed on those platforms.
    # You can use the window refresh callback to redraw the contents of your window
    # when necessary during such operations.
    #
    # Do not assume that callbacks you set will only be called
    # in response to event processing functions like this one.
    # While it is necessary to poll for events,
    # window systems that require GLFW to register callbacks of its own
    # can pass events to GLFW in response to many window system function calls.
    # GLFW will pass those events on to the application callbacks before returning.
    #
    # Event processing is not required for joystick input to work.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def self.wait_events
      ErrorHandling.static_checked { LibGLFW.wait_events }
    end

    # Puts the calling thread to sleep until at least one event is available in the event queue,
    # or until the specified timeout is reached.
    # If one or more events are available, it behaves exactly like `#poll_events`,
    # i.e. the events in the queue are processed and the function then returns immediately.
    # Processing events will cause the window and input callbacks associated with those events to be called.
    #
    # The *timeout* value must be a positive finite number.
    # It is the maximum amount of time, in seconds, to wait.
    #
    # Since not all events are associated with callbacks,
    # this function may return without a callback having been called even if you are monitoring all callbacks.
    #
    # On some platforms, a window move, resize or menu operation will cause event processing to block.
    # This is due to how event processing is designed on those platforms.
    # You can use the window refresh callback to redraw the contents of your window
    # when necessary during such operations.
    #
    # Do not assume that callbacks you set will only be called
    # in response to event processing functions like this one.
    # While it is necessary to poll for events,
    # window systems that require GLFW to register callbacks of its own
    # can pass events to GLFW in response to many window system function calls.
    # GLFW will pass those events on to the application callbacks before returning.
    #
    # Event processing is not required for joystick input to work.
    #
    # Possible errors that could be raised are: `NotInitializedError`, `PlatformError`, and `ArgumentError`.
    def self.wait_events(timeout)
      ErrorHandling.static_checked { LibGLFW.wait_events_timeout(timeout) }
    rescue ex : InvalidValueError
      raise ArgumentError.new(ex.message)
    end

    # Posts an empty event from the current thread to the event queue,
    # causing `#wait_events` to return.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def self.post_empty_event
      ErrorHandling.static_checked { LibGLFW.post_empty_event }
    end
  end
end
