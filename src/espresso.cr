require "glfw"
require "semantic_version"
require "./espresso/**"

# Lightweight wrapper around GLFW for Crystal.
module Espresso
  extend self
  include ErrorHandling
  include BoolConversion

  # Current version of the shard.
  VERSION = "0.1.3"

  # Prepares GLFW so that it can be used.
  # This method must be called prior
  # to any features that require initialization.
  # If the initialization fails, a `GLFWError` will be raised.
  #
  # Before exiting the program, and after GLFW is no longer needed,
  # the `#terminate` method must be called.
  # It is recommended to use `#run` instead of this method.
  #
  # Arguments to this method are initialization hints.
  # When unspecified (nil), the hints will use their default value.
  # Specify true or false for the hints as needed.
  #
  # *joystick_hat_buttons* specifies whether to also expose joystick hats as buttons,
  # for compatibility with earlier versions of GLFW that did not have this feature.
  #
  # macOS specific hints:
  #
  # *cocoa_chdir_resources* pecifies whether to set the current directory
  # to the application to the Contents/Resources subdirectory of the application's bundle, if present.
  #
  # *cocoa_menubar* specifies whether to create a basic menu bar, either from a nib or manually,
  # when the first window is created, which is when AppKit is initialized.
  #
  # Calling this method when GLFW is already initialized does nothing.
  #
  # A `PlatformError` will be raised if GLFW couldn't be initialized.
  def init(joystick_hat_buttons : Bool? = nil,
           cocoa_chdir_resources : Bool? = nil,
           cocoa_menubar : Bool? = nil) : Nil
    init_hint(LibGLFW::InitHint::JoystickHatButtons, joystick_hat_buttons) unless joystick_hat_buttons.nil?
    init_hint(LibGLFW::InitHint::CocoaChdirResources, cocoa_chdir_resources) unless cocoa_chdir_resources.nil?
    init_hint(LibGLFW::InitHint::CocoaMenubar, cocoa_menubar) unless cocoa_menubar.nil?
    expect_truthy { LibGLFW.init }
  end

  # Utility method for setting an initialization hint.
  # Converts *flag* from a boolean to an GLFW boolean integer
  # and sets the corresponding *hint*.
  private def init_hint(hint, flag)
    value = bool_to_int(flag)
    LibGLFW.init_hint(hint, value)
  end

  # Cleans up resources used by GLFW and and changes it made to the system.
  # This method must be called after GLFW is no longer used
  # and before the program exits.
  # Once GLFW is terminated, it must be reinitialized before using it again.
  #
  # Calling this method when GLFW is already terminated does nothing.
  #
  # A `PlatformError` can be raised if GLFW couldn't be terminated.
  def terminate : Nil
    checked { LibGLFW.terminate }
  end

  # Initializes GLFW and yields for the duration it is usable.
  # GLFW is automatically terminated after the block completes,
  # even if an uncaught exception is raised.
  #
  # Arguments to this method are initialization hints.
  # When unspecified (nil), the hints will use their default value.
  # Specify true or false for the hints as needed.
  # See `#init` for details on what these hints do.
  #
  # The value of the block is returned by this method.
  #
  # Calling this method when GLFW is already initialized does nothing.
  #
  # A `PlatformError` will be raised if GLFW couldn't be initialized.
  #
  # Usage:
  # ```
  # Espresso.run do
  #   # Use GLFW here.
  # end
  # ```
  def run(joystick_hat_buttons : Bool? = nil,
          cocoa_chdir_resources : Bool? = nil,
          cocoa_menubar : Bool? = nil)
    init(joystick_hat_buttons, cocoa_chdir_resources, cocoa_menubar)
    yield
  ensure
    terminate
  end

  # Version of GLFW that Espresso was compiled against.
  # This should match `#runtime_version` to have consistent/expected behavior.
  # A `SemanticVersion` is returned.
  def compiled_version
    SemanticVersion.new(
      LibGLFW::VERSION_MAJOR,
      LibGLFW::VERSION_MINOR,
      LibGLFW::VERSION_REVISION
    )
  end

  # Version of GLFW that is loaded and in-use by Espresso.
  # This should match `#compiled_version` to have consistent/expected behavior.
  # A `SemanticVersion` is returned.
  def runtime_version
    LibGLFW.get_version(out major, out minor, out revision)
    SemanticVersion.new(major, minor, revision)
  end

  # Version of GLFW that is loaded and in-use by Espresso.
  # A `SemanticVersion` is returned.
  def version
    runtime_version
  end

  # Compiled version string produced by GLFW.
  # Includes the version string and
  # additional compilation and environment information.
  def version_string
    String.new(LibGLFW.get_version_string)
  end
end
