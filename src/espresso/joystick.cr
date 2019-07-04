require "glfw"
require "./bool_conversion"
require "./error_handling"

module Espresso
  struct Joystick
    include BoolConversion
    include ErrorHandling

    protected def initialize(@id : LibGLFW::Joystick)
    end

    def self.all
      LibGLFW::Joystick.values.map do |id|
        Joystick.new(id)
      end
    end

    def self.each
      LibGLFW::Joystick.each do |id|
        yield Joystick.new(id)
      end
    end

    def self.connected
      all.select(&.connected?)
    end

    def self.each_connected
      each do |joystick|
        yield joystick if joystick.connected?
      end
    end

    def connected?
      value = expect_truthy { LibGLFW.joystick_present(@id) }
      int_to_bool(value)
    end

    def axes?
      count = uninitialized Int32
      pointer = expect_truthy { LibGLFW.get_joystick_axes(@id, pointerof(count)) }
      pointer ? Slice.new(pointer, count) : nil
    end

    def axes
      axes? || raise "Joystick disconnected"
    end

    def buttons?
    end

    def buttons
    end

    def hats?
    end

    def hats
    end

    def name?
      chars = expect_truthy { LibGLFW.get_joystick_name(@id) }
      chars ? String.new(chars) : nil
    end

    def name
      name? || raise "Joystick disconnected"
    end

    def guid?
      chars = expect_truthy { LibGLFW.get_joystick_guid(@id) }
      chars ? String.new(chars) : nil
    end

    def guid
      guid? || raise "Joystick disconnected"
    end

    def user_pointer
    end

    def user_pointer=(pointer)
    end
  end
end
