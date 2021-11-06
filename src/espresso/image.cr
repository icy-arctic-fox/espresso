module Espresso
  # Describes a single 2D image.
  #
  # The image data is 32-bit, little-endian, non-premultiplied RGBA,
  # i.e. eight bits per channel with the red channel first.
  # The pixels are arranged canonically as sequential rows,
  # starting from the top-left corner.
  struct Image
    # Width, in pixels, of this image.
    getter width : Int32

    # Height, in pixels, of this image.
    getter height : Int32

    # Raw pixel data of this image.
    # The pixels are arranged left-to-right, top-to-bottom.
    # Each pixel is 4 bytes, little-endian, and ordered as RGBA.
    getter pixels : Bytes

    # Creates an empty image of the specified size.
    def initialize(@width, @height)
      @pixels = Bytes.new(@width * @height * sizeof(Int32))
    end

    # Returns a GLFW image structure.
    def to_unsafe
      image = LibGLFW::Image.new
      image.width = width
      image.height = height
      image.pixels = pixels
      image
    end
  end
end
