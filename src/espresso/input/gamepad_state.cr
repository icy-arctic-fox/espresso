require "./gamepad_axis"
require "./gamepad_button"

module Espresso
  # Describes the input state of a gamepad.
  #
  # The `#guide` button may not be available for input
  # as it is often hooked by the system or the Steam client.
  #
  # Not all devices have all the buttons or axes defined by this type.
  # Unavailable buttons and axes will always report `ButtonState::Released` and 0.0 respectively.
  struct GamepadState
    # Defines methods to get the state of a button and whether it is pressed.
    private macro button(name)
      # Gets the state of the button.
      # This will be one of `ButtonState::Pressed` or `ButtonState::Released`.
      def {{name.id.gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
              .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
              .gsub(/D_Pad/, "DPad").downcase}} : GamepadState
        buttons[GamepadButton::{{name.id}}]
      end

      # Indicates whether the button is currently pressed.
      def {{name.id.gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
              .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
              .gsub(/D_Pad/, "DPad").downcase}}?
        buttons[GamepadButton::{{name.id}}].pressed?
      end
    end

    # Defines a method to retrieve an axis value.
    private macro axis(name)
      # Gets the state of the axis, in the range -1.0 to 1.0 inclusive.
      def {{name.id.gsub(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
              .gsub(/([a-z\d])([A-Z])/, "\\1_\\2").downcase}} : GamepadAxis
        axes[GamepadAxis::{{name.id}}]
      end
    end

    # Creates the gamepad state with an underlying GLFW gamepad state.
    protected def initialize(@state : LibGLFW::GamepadState)
    end

    # The states of each gamepad button,
    # `ButtonState::Pressed` or `ButtonState::Released`.
    def buttons : Indexable(ButtonState)
      @state.buttons
    end

    # The states of each gamepad axis,
    # in the range -1.0 to 1.0 inclusive.
    def axes : Indexable(Float)
      @state.axes
    end

    {% for b in GamepadButton.constants %}
      button {{b}}
    {% end %}

    {% for a in GamepadAxis.constants %}
      axis {{a}}
    {% end %}

    # Returns the underlying GLFW gamepad state structure.
    def to_unsafe
      @state
    end
  end
end
