require "glfw"
require "semantic_version"

# Lightweight wrapper around GLFW for Crystal.
module Espresso
  extend self

  # Current version of the shard.
  VERSION = "0.1.0"

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
