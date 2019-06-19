require "glfw"
require "./error_handling"
require "./monitor"

module Espresso
  # Encapsulates both a window and a context.
  # Windows can be created with the `#new` and `#full_screen` methods.
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
  # see `glfwGetWindowAttrib`, `glfwGetWindowSize`, and `glfwGetFramebufferSize`.
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
  # you can switch it between windowed and full screen mode with `glfwSetWindowMonitor`.
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
  # To set a different icon, see `glfwSetWindowIcon`.
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
  # Menu bar creation can be disabled entirely with the `WindowBuilder#cocoa_menubar=` init hint.
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
    include ErrorHandling

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
      pointer = expect_truthy do
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
      pointer = expect_truthy do
        LibGLFW.create_window(width, height, title, monitor, share)
      end
      Window.new(pointer)
    end
  end
end
