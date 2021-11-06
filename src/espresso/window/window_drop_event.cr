require "./window_event"

module Espresso
  # Event triggered when one or more files are dropped onto the window.
  struct WindowDropEvent < WindowEvent
    # List of file paths.
    getter paths : Array(String)

    # Creates the event.
    protected def initialize(pointer, count, paths)
      super(pointer)
      # Use Slice for safer and easier pointer access.
      slice = Slice.new(paths, count, read_only: true)
      @paths = Array.new(count) { |i| String.new(slice[i]) }
    end
  end
end
