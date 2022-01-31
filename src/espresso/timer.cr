require "./error_handling"

module Espresso
  # High-resolution time input.
  class Timer
    include ErrorHandling

    @accum = 0_u64
    @start = 0_u64

    # Indicates whether the timer is currently running.
    getter? running : Bool

    # Creates and optionally starts a new timer.
    def initialize(@running = false)
      @start = Timer.value
    end

    # Raw value of the current timer.
    def value
      running? ? runtime + @accum : @accum
    end

    # Time elapsed since the start time.
    private def runtime
      Timer.value - @start
    end

    # Starts (or restarts) the timer.
    # If multiple consecutive calls are made to this method,
    # then it has the effect of restarting the the current time segment at the last call.
    # Any previous time accumulated before this call is kept.
    # Call `#reset` to completely restart the timer to zero.
    def start : Nil
      @running = true
      @start = Timer.value
    end

    # Stops the timer.
    def stop : Nil
      return unless running?

      @accum += runtime
      @running = false
    end

    # Resets the timer back to zero.
    # The timer will continue running if it already was.
    def reset : Nil
      @accum = 0_u64
      @start = Timer.value
    end

    # Total elapsed time in seconds.
    def seconds : Float64
      value.to_f64 / Timer.frequency
    end

    # Total elapsed time in nanoseconds (10^-9).
    # Might be rounded depending on the system's precision.
    def nanoseconds : Float64
      value.to_f64 / (Timer.frequency / 1_000_000_000_f64)
    end

    # Total elapsed time in microseconds (10^-6).
    # Might be rounded depending on the system's precision.
    def microseconds : Float64
      value.to_f64 / (Timer.frequency / 1_000_000_f64)
    end

    # Total elapsed time in milliseconds (10^-3).
    # Might be rounded depending on the system's precision.
    def milliseconds : Float64
      value.to_f64 / (Timer.frequency / 1_000_f64)
    end

    # Creates a `Time::Span` from the timer's value.
    def span : Time::Span
      Time::Span.new(nanoseconds: nanoseconds.to_i64)
    end

    # Measures how long a block takes to execute and returns a time span.
    def self.measure : Time::Span
      timer = Timer.new(true)
      yield
      timer.span
    end

    # Retrieves the value (in seconds) of the GLFW timer.
    # Unless the timer has been set using `#global=`,
    # the timer measures time elapsed since GLFW was initialized.
    #
    # The resolution of the timer is system dependent,
    # but is usually on the order of a few micro- or nanoseconds.
    # It uses the highest-resolution monotonic time source on each supported platform.
    def self.global
      expect_not(0_f64) { LibGLFW.get_time }
    end

    # Sets the value (in seconds) of the GLFW timer.
    # It then continues to count up from that value.
    # The value must be a positive finite number less than or equal to 18,446,744,073.0,
    # which is approximately 584.5 years.
    #
    # The upper limit of the timer is calculated as:
    # `floor((2^64 - 1) / 10^9)`
    # and is due to implementations storing nanoseconds in 64 bits.
    # The limit may be increased in the future.
    def self.global=(time)
      checked { LibGLFW.set_time(time) }
    end

    # Current value of the raw timer,
    # measured in `1 / frequency` seconds.
    # To get the frequency, call `#frequency`.
    def self.value
      expect_not(0_u64) { LibGLFW.get_timer_value }
    end

    # Frequency, in Hz, of the raw timer.
    #
    # See also: `Timer#value`.
    def self.frequency
      expect_not(0_u64) { LibGLFW.get_timer_frequency }
    end
  end
end
