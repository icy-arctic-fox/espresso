require "./window_event"

module Espresso
  # Event triggered when one or more files are dropped onto the window.
  struct WindowDropEvent < WindowEvent
    # List of file paths.
    getter paths : Slice(String)

    # Creates the event.
    protected def initialize(pointer, count, paths_pointer)
      super(pointer)
      slice = Slice.new(paths_pointer, count, read_only: true)
      @paths = slice.map(read_only: true) { |str_ptr| String.new(str_ptr) }
    end
  end
end
