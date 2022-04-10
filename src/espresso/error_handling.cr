require "./errors/*"

# Don't show this file in stack traces.
Exception::CallStack.skip(__FILE__)

module Espresso
  # Mix-in for handling errors from GLFW.
  private module ErrorHandling
    macro included
      extend ErrorHandling
    end

    # Checks if an error occurred in GLFW
    # and raises an exception if one did.
    private def check_error
      code = LibGLFW.get_error(out description)
      return if code.no_error?

      raise translate_error(code, description)
    end

    # Checks for errors from GLFW after a method has been called.
    # Pass a block to this method that calls *one* GLFW function.
    # The value of the block will be returned if no error occurred.
    # Otherwise, the error will be translated and raised.
    private def checked
      yield.tap { check_error }
    end

    # Expects a GLFW function to return a truthy value.
    # The return value of the function is checked
    # to be not false, nil, or integer false (zero).
    # Pass a block to this method that calls *one* GLFW function.
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

    # Expects a GLFW function to not return a specific value.
    # The return value of the function is checked to be not the given *value*.
    # Pass a block to this method that calls *one* GLFW function.
    # The value of the block will be returned if no error occurred.
    # Otherwise, an error will be raised.
    #
    # An exception will be raised only if an error occurred.
    # The error check will only happen if the block returns *value*.
    private def expect_not(value)
      yield.tap do |result|
        check_error if result == value
      end
    end

    # Creates an error from the given code a description.
    # The *code* indicates which type of error to create.
    # The *description* is the character array provided by GLFW.
    #
    # ameba:disable Metrics/CyclomaticComplexity
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
