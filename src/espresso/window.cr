require "./error_handling"
require "./window/**"

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
  # the specified window size and position may be overridden by previously saved values.
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

    # Data stored alongside the window instance in GLFW as the user pointer.
    WindowUserData.def_getter

    # Creates a window object by wrapping a GLFW window pointer.
    protected def initialize(@pointer : LibGLFW::Window, @user_data : WindowUserData? = nil)
    end

    # Creates a window and its associated OpenGL or OpenGL ES context.
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
    def initialize(width : Int32, height : Int32, title : String, share : Window? = nil)
      @pointer = expect_truthy do
        LibGLFW.create_window(width, height, title, nil, share)
      end
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
    def self.full_screen(title : String, monitor : Monitor = Monitor.primary, share : Window? = nil)
      size = monitor.size
      full_screen(title, monitor, size.width, size.height, share)
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
    def self.full_screen(title : String, width : Int32, height : Int32,
                         monitor : Monitor = Monitor.primary, share : Window? = nil)
      pointer = expect_truthy do
        LibGLFW.create_window(width, height, title, monitor, share)
      end
      new(pointer)
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
    # The *share* argument is the window whose context to share resources with.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.open(width : Int32, height : Int32, title : String, share : Window? = nil, & : Window -> _)
      new(width, height, title, share).tap do |window|
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
    # The *share* argument is the window whose context to share resources with.
    #
    # The width and height of the window match the size of the monitor's current display mode.
    #
    # Possible errors that could be raised are:
    # `NotInitializedError`, `InvalidEnumError`, `InvalidValueError`, `APIUnavailableError`,
    # `VersionUnavailableError`, `FormatUnavailableError`, and `PlatformError`.
    def self.full_screen(title : String, monitor : Monitor = Monitor.primary, share : Window? = nil, & : Window -> _)
      full_screen(title, monitor, share).tap do |window|
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
    def self.full_screen(title : String, width : Int32, height : Int32,
                         monitor : Monitor = Monitor.primary, share : Window? = nil, & : Window -> _)
      full_screen(title, monitor, width, height, share).tap do |window|
        window.current!
        yield window
      ensure
        window.destroy!
      end
    end

    # Destroys this window and its context.
    # On calling this method, no further callbacks will be called for this window.
    #
    # If the context of this window is current on the main thread, it is detached before being destroyed.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **Do not** attempt to use the window after it has been destroyed.
    def destroy! : Nil
      checked { LibGLFW.destroy_window(@pointer) }
      return unless user_data = @user_data

      WindowUserData.instances.delete(user_data)
    end

    # Retrieves the mouse instance for this window.
    # Even though the system may only have one logical mouse attached,
    # mouse instances are tied to a window.
    def mouse : Mouse
      Mouse.new(@pointer)
    end

    # Retrieves the keyboard instance for this window.
    # Even though the system may only have one logical keyboard attached,
    # keyboard instances are tied to a window.
    def keyboard : Keyboard
      Keyboard.new(@pointer)
    end

    # Checks whether the window should be closed.
    #
    # See also: `#closing=`
    def closing?
      value = checked { LibGLFW.window_should_close(@pointer) }
      value.to_bool
    end

    # Sets whether the window should be closed.
    # This can be used to override the user's attempt to close the window,
    # or to signal that it should be closed.
    #
    # See also: `#closing?`
    def closing=(flag)
      value = LibGLFW::Bool.new(flag)
      checked { LibGLFW.set_window_should_close(@pointer, value) }
    end

    # Updates the window's title.
    # The new *title* is specified as a UTF-8 encoded string.
    def title=(title)
      checked { LibGLFW.set_window_title(@pointer, title) }
    end

    # Sets the icon of this window.
    # If passed an array of candidate images,
    # those of or closest to the sizes desired by the system are selected.
    # If no images are specified, the window reverts to its default icon.
    #
    # The array of *images* should be a set of `Image` instances.
    #
    # The desired image sizes varies depending on platform and system settings.
    # The selected images will be rescaled as needed.
    # Good sizes include 16x16, 32x32 and 48x48.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # **macOS:** The GLFW window has no icon,
    # as it is not a document window, so this method does nothing.
    # The dock icon will be the same as the application bundle's icon.
    # For more information on bundles, see the [Bundle Programming Guide](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/)
    # in the Mac Developer Library.
    #
    # **Wayland:** There is no existing protocol to change an icon,
    # the window will thus inherit the one defined in the application's desktop file.
    # This method always raises `PlatformError`.
    def icon=(images)
      icon = images.map &.to_unsafe
      checked { LibGLFW.set_window_icon(@pointer, icon.size, icon) }
    end

    # Resets the window's icon to the default icon.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def reset_icon : Nil
      checked { LibGLFW.set_window_icon(@pointer, 0, nil) }
    end

    # Retrieves the position, in screen coordinates, of the upper-left corner
    # of the content area of this window.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def position : Position
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
    def move(x, y) : Nil
      checked { LibGLFW.set_window_pos(@pointer, x, y) }
    end

    # Retrieves the size, in screen coordinates, of the content area of this window.
    # If you wish to retrieve the size of the framebuffer of the window in pixels, see `#framebuffer_size`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def size : Size
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
    def resize(width, height) : Nil
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
    def limit_size(min_width = nil, min_height = nil, max_width = nil, max_height = nil) : Nil
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
    def unlimit_size : Nil
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
    def aspect_ratio(numerator, denominator) : Nil
      checked { LibGLFW.set_window_aspect_ratio(@pointer, numerator, denominator) }
    end

    # Disables the aspect ratio limit.
    # Allows the window to be resized without restricting to a given aspect ratio.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def disable_aspect_ratio : Nil
      aspect_ratio(LibGLFW::DONT_CARE, LibGLFW::DONT_CARE)
    end

    # Retrieves the size, in pixels, of the framebuffer of this window.
    # If you wish to retrieve the size of the window in screen coordinates, see `#size`.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def framebuffer_size : Size
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
    def frame_size : FrameSize
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
    def scale : Scale
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
    def opacity : Float
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
    def iconify : Nil
      checked { LibGLFW.iconify_window(@pointer) }
    end

    # Restores this window if it was previously iconified (minimized) or maximized.
    # If the window is already restored, this function does nothing.
    #
    # If the specified window is a full screen window,
    # the resolution chosen for the window is restored on the selected monitor.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def restore : Nil
      checked { LibGLFW.restore_window(@pointer) }
    end

    # Maximizes this window if it was previously not maximized.
    # If the window is already maximized, this function does nothing.
    #
    # If the specified window is a full screen window, this function does nothing.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def maximize : Nil
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
    def show : Nil
      checked { LibGLFW.show_window(@pointer) }
    end

    # Hides this window if it was previously visible.
    # If the window is already hidden or is in full screen mode, this function does nothing.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def hide : Nil
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
    def focus : Nil
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
    def request_attention : Nil
      checked { LibGLFW.request_window_attention(@pointer) }
    end

    # Retrieves the contents of the system clipboard,
    # if it contains or is convertible to a UTF-8 encoded string.
    # If the clipboard is empty or if its contents cannot be converted,
    # a `FormatUnavailableError` is raised.
    #
    # Possible errors that could be raised are: `NotInitializedError`, `PlatformError`, and `FormatUnavailableError`.
    def clipboard : String
      chars = expect_truthy { LibGLFW.get_clipboard_string(@pointer) }
      String.new(chars)
    end

    # Retrieves the contents of the system clipboard,
    # if it contains or is convertible to a UTF-8 encoded string.
    # If the clipboard is empty or if its contents cannot be converted,
    # nil is returned..
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def clipboard? : String?
      chars = LibGLFW.get_clipboard_string(@pointer)
      String.new(chars) if chars
    end

    # Sets the contents of the system clipboard,
    # to the specified UTF-8 encoded *string*.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def clipboard=(string)
      checked { LibGLFW.set_clipboard_string(@pointer, string) }
    end

    # Retrieves the contents of the system clipboard,
    # if it contains or is convertible to a UTF-8 encoded string.
    # If the clipboard is empty or if its contents cannot be converted,
    # a `FormatUnavailableError` is raised.
    #
    # Possible errors that could be raised are: `NotInitializedError`, `PlatformError`, and `FormatUnavailableError`.
    def self.clipboard : String
      chars = expect_truthy { LibGLFW.get_clipboard_string(nil) }
      String.new(chars)
    end

    # Sets the contents of the system clipboard,
    # to the specified UTF-8 encoded *string*.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def self.clipboard=(string)
      checked { LibGLFW.set_clipboard_string(nil, string) }
    end

    # Retrieves the contents of the system clipboard,
    # if it contains or is convertible to a UTF-8 encoded string.
    # If the clipboard is empty or if its contents cannot be converted,
    # nil is returned.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def self.clipboard? : String?
      chars = LibGLFW.get_clipboard_string(nil)
      String.new(chars) if chars
    end

    # Attempts to retrieve the monitor the full screen window is using.
    # If the window isn't full screen, then nil is returned.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    def monitor? : Monitor?
      pointer = expect_truthy { LibGLFW.get_window_monitor(@pointer) }
      Monitor.new(pointer) if pointer
    end

    # Retrieves the monitor the full screen window is using.
    # If the window isn't full screen, then an error is raised.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `NilAssertionError`.
    def monitor : Monitor
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
    def full_screen! : Nil
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
    def full_screen!(monitor) : Nil
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
    def full_screen!(monitor, width, height) : Nil
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
    def full_screen!(monitor, width, height, refresh_rate) : Nil
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
    def windowed!(x, y, width, height) : Nil
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
    def user_pointer : Pointer
      user_data.pointer
    end

    # Updates the value of the user-defined pointer for this window.
    # This can be used for any purpose you need and will not be modified by GLFW.
    # The value will be kept until the window is destroyed or until the library is terminated.
    # The initial value is nil.
    #
    # Possible errors that could be raised are: `NotInitializedError`.
    def user_pointer=(pointer)
      user_data.pointer = pointer
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
    def swap_buffers : Nil
      checked { LibGLFW.swap_buffers(@pointer) }
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
    def current! : Nil
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
    def self.current? : Window?
      pointer = expect_truthy { LibGLFW.get_current_context }
      Window.new(pointer) if pointer
    end

    # Returns the window whose OpenGL or OpenGL ES context is current on the calling thread.
    # This will raise a `NilAssertionError` if no window is current.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `NilAssertionError`.
    def self.current : self
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
    def self.poll_events : Nil
      checked { LibGLFW.poll_events }
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
    def self.wait_events : Nil
      checked { LibGLFW.wait_events }
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
    def self.wait_events(timeout) : Nil
      checked { LibGLFW.wait_events_timeout(timeout) }
    rescue ex : InvalidValueError
      raise ArgumentError.new(ex.message)
    end

    # Posts an empty event from the current thread to the event queue,
    # causing `#wait_events` to return.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    def self.post_empty_event : Nil
      checked { LibGLFW.post_empty_event }
    end

    # Sets the swap interval for the current OpenGL or OpenGL ES context,
    # i.e. the number of screen updates to wait from the time `#swap_buffers` was called
    # before swapping the buffers and returning.
    # This is sometimes called vertical synchronization,
    # vertical retrace synchronization, or just vsync.
    #
    # A context that supports either of the `WGL_EXT_swap_control_tear` and `GLX_EXT_swap_control_tear` extensions
    # also accepts negative swap intervals,
    # which allows the driver to swap immediately even if a frame arrives a little bit late.
    # You can check for these extensions with `Espresso#extension_supported?`.
    #
    # A context must be current on the calling thread.
    # Calling this method without a current context will raise `NoCurrentContextError`.
    #
    # This method does not apply to Vulkan.
    # If you are rendering with Vulkan, see the present mode of your swapchain instead.
    #
    # This method is not called during context creation,
    # leaving the swap interval set to whatever is the default on that platform.
    # This is done because some swap interval extensions used by GLFW
    # do not allow the swap interval to be reset to zero once it has been set to a non-zero value.
    #
    # Some GPU drivers do not honor the requested swap interval,
    # either because of a user setting that overrides the application's request or due to bugs in the driver.
    def self.swap_interval=(interval)
      checked { LibGLFW.swap_interval(interval) }
    end
  end
end
