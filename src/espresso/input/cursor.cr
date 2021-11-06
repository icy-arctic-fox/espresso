require "../image"
require "./cursor_shape"

module Espresso
  # Custom or standard cursor to display the mouse's location in a window.
  struct Cursor
    # Creates a new custom cursor from an image.
    #
    # Specify the cursor's appearance with the *image* argument.
    # The *x* and *y* arguments specify the cursor's hot-spot.
    def initialize(image, x = 0, y = 0)
      glfw_image = image.to_unsafe
      @pointer = expect_truthy { LibGLFW.create_cursor(pointerof(glfw_image), x, y) }
    end

    # Creates a cursor from a GLFW cursor pointer.
    protected def initialize(@pointer : LibGLFW::Cursor)
    end

    # Destroys the cursor and releases any resources it used.
    # If the cursor is current for any window,
    # that window will revert to the default cursor.
    # This does not affect the cursor mode.
    # All remaining cursors are destroyed when `Espresso#terminate` is called.
    #
    # **Do not** attempt to use the cursor after destroying it.
    def destroy!
      checked { LibGLFW.destroy_cursor(@pointer) }
    end

    # Returns the underlying GLFW cursor pointer.
    def to_unsafe
      @pointer
    end

    # Creates a cursor from one of the standard shapes.
    # See `CursorShape` for available options.
    def self.standard(type)
      pointer = expect_truthy { LibGLFW.create_standard_cursor(type) }
      Cursor.new(pointer)
    end

    {% for name in CursorShape.constants %}
    # Creates a standard {{name}} cursor shape.
    def self.{{name.id.gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
                 .gsub(/([a-z\d])([A-Z])/, "\\1_\\2").downcase}}
      standard(CursorShape::{{name}})
    end
    {% end %}
  end
end
