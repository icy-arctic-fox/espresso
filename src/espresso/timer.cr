require "glfw"
require "error_handling"

module Espresso
  # High-resolution time input.
  class Timer
    # Retrieves the value (in seconds) of the GLFW timer.
    # Unless the timer has been set using `#global=`,
    # the timer measures time elapsed since GLFW was initialized.
    #
    # The resolution of the timer is system dependent,
    # but is usually on the order of a few micro- or nanoseconds.
    # It uses the highest-resolution monotonic time source on each supported platform.
    def self.global
      ErrorHandling.static_expect_not(0f64) { LibGLFW.get_time }
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
      ErrorHandling.static_checked { LibGLFW.set_time(time) }
    end

    # Current value of the raw timer,
    # measured in `1 / frequency` seconds.
    # To get the frequency, call `#frequency`.
    def self.value
      ErrorHandling.static_expect_not(0u64) { LibGLFW.get_timer_value }
    end

    # Frequency, in Hz, of the raw timer.
    #
    # See also: `#value`.
    def self.frequency
      ErrorHandling.static_expect_not(0u64) { LibGLFW.get_timer_frequency }
    end
  end
end
