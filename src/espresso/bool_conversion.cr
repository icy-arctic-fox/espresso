require "glfw"

module Espresso
  # Mix-in for converting between Crystal booleans and GLFW integer booleans.
  private module BoolConversion
    # Checks whether an integer is a truthy value.
    # The *value* argument can be a `LibGLFW::Bool` or integer.
    # Returns true if *value* is not `LibGLFW::Bool::False` or zero.
    private def int_to_bool(value)
      value.to_i != LibGLFW::Bool::False.to_i
    end

    # Converts a native Crystal boolean to an integer GLFW expects.
    # True is returned if *value* is truthy (not false or nil).
    private def bool_to_int(value)
      value ? LibGLFW::Bool::True : LibGLFW::Bool::False
    end
  end
end
