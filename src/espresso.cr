require "glfw"
require "semantic_version"
require "./espresso/**"

# Lightweight wrapper around GLFW for Crystal.
module Espresso
  extend self
  include ErrorHandling

  # Current version of the shard.
  VERSION = "0.1.0"

  # Prepares GLFW so that it can be used.
  # This method must be called prior
  # to any features that require initialization.
  # If the initialization fails, a `GLFWError` will be raised.
  #
  # Before exiting the program, and after GLFW is no longer needed,
  # the `#terminate` method must be called.
  # It is recommended to use `#run` instead of this method.
  #
  # Calling this method when GLFW is already initialized does nothing.
  #
  # A `PlatformError` will be raised if GLFW couldn't be initialized.
  def init : Nil
    expect_truthy { LibGLFW.init }
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
  def run
    init
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
