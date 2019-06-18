require "./glfw_error"
require "./not_initialized_error"
require "./no_current_context_error"
require "./invalid_enum_error"
require "./invalid_value_error"
require "./out_of_memory_error"
require "./api_unavailable_error"
require "./version_unavailable_error"
require "./platform_error"
require "./format_unavailable_error"
require "./no_window_context_error"

module Espresso
  # Mix-in for handling errors from GLFW.
  private module ErrorHandling
    extend self

    # Checks if an error occurred in GLFW
    # and raises an exception if one did.
    private def check_error
      code = LibGLFW.get_error(out description)
      if code != LibGLFW::ErrorCode::NoError
        raise translate_error(code, description)
      end
    end

    # Checks for errors from GLFW after a method has been called.
    # Pass a block to this method that calls *one* GLFW method.
    # The value of the block will be returned if no error occurred.
    # Otherwise, the error will be translated and raised.
    private def checked
      yield.tap { check_error }
    end

    # Same as `#checked`, but for static invocations.
    protected def self.static_checked(&block : -> _)
      checked(&block)
    end

    # Expects a GLFW function to return a truthy value.
    # The return value of the method is checked
    # to be not false, nil, or integer false (zero).
    # Pass a block to this method that calls *one* GLFW method.
    # The value of the block will be returned if no error occurred.
    # Otherwise, an error will be raised.
    #
    # An exception will be raised only if an error occurred.
    # The error check will only happen if the block returns non-truthy.
    private def expect_truthy
      yield.tap do |result|
        check_error if !result || result == LibGLFW::Bool::False
      end
    end

    # Same as `#expect_truthy`, but for static invocations.
    protected def self.static_expect_truthy(&block : -> _)
      expect_truthy(&block)
    end

    # Creates an error from the given code a description.
    # The *code* indicates which type of error to create.
    # The *description* is the character array provided by GLFW.
    private def translate_error(code, description)
      klass = case code
              when LibGLFW::ErrorCode::NotInitialized     then NotInitializedError
              when LibGLFW::ErrorCode::NoCurrentContext   then NoCurrentContextError
              when LibGLFW::ErrorCode::InvalidEnum        then InvalidEnumError
              when LibGLFW::ErrorCode::InvalidValue       then InvalidValueError
              when LibGLFW::ErrorCode::OutOfMemory        then OutOfMemoryError
              when LibGLFW::ErrorCode::APIUnavailable     then APIUnavailableError
              when LibGLFW::ErrorCode::VersionUnavailable then VersionUnavailableError
              when LibGLFW::ErrorCode::PlatformError      then PlatformError
              when LibGLFW::ErrorCode::FormatUnavailable  then FormatUnavailableError
              when LibGLFW::ErrorCode::NoWindowContext    then NoWindowContextError
              else
                raise "Unrecognized error code from GLFW - #{code}"
              end

      message = String.new(description)
      klass.new(message)
    end
  end
end
