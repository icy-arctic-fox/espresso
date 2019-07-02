require "glfw"
require "./bool_conversion"
require "./error_handling"
require "./event_handling"
require "./key"

module Espresso
  # Information about the keyboard that is associated with a window.
  # Each `Window` has its own keyboard instance with properties specific to that window.
  # To retrieve a keyboard instance, use `Window#keyboard`.
  #
  # GLFW divides keyboard input into two categories; key events and character events.
  # Key events relate to actual physical keyboard keys,
  # whereas character events relate to the Unicode code points generated by pressing some of them.
  #
  # Keys and characters do not map 1:1.
  # A single key press may produce several characters,
  # and a single character may require several keys to produce.
  # This may not be the case on your machine,
  # but your users are likely not all using the same keyboard layout,
  # input method or even operating system as you.
  struct Keyboard
    include BoolConversion
    include ErrorHandling
    include EventHandling

    # Creates the keyboard instance from a GLFW window pointer.
    protected def initialize(@pointer : LibGLFW::Window)
    end

    # Retrieves the last state reported for the specified key to the associated window.
    # The returned state is one of `KeyState::Pressed` or `KeyState::Released`.
    # The higher-level action `KeyState::Repeated` is only reported to the `#on_key` event.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns `KeyState::Pressed` the first time you call it for a key that was pressed,
    # even if that key has already been released.
    #
    # The key method deal with physical keys,
    # with key tokens (see: `Key`) named after their use on the standard US keyboard layout.
    # If you want to input text, use the Unicode character callback instead (see `#on_char`).
    #
    # The modifier key bit masks are not key tokens and cannot be used with this method.
    #
    # **Do not use this method** to implement text input.
    def key(key)
      value = expect_truthy { LibGLFW.get_key(@pointer, key) }
      KeyState.from_value(value.to_i)
    end

    # Determines whether the last state reported for the specified key is pressed.
    #
    # If the `#sticky?` input mode is enabled,
    # this method returns true the first time you call it for a key that was pressed,
    # even if that key has already been released.
    def key?(key)
      self.key(key).pressed?
    end

    # Indicates whether stick keys is enabled.
    # This is not the infamous [Windows sticky keys](https://en.wikipedia.org/wiki/Sticky_keys).
    # If sticky keys are enabled, a key press will ensure that `#key` returns `KeyState::Pressed`
    # the next time it is called even if the key had been released before the call.
    # This is useful when you are only interested in whether keys have been pressed
    # but not when or in which order.
    #
    # See also: `#sticky=`
    def sticky?
      value = expect_truthy { LibGLFW.get_input_mode(@pointer, LibGLFW::InputMode::StickyKeys) }
      int_to_bool(value)
    end

    # Enables or disables sticky keys.
    # This is not the infamous [Windows sticky keys](https://en.wikipedia.org/wiki/Sticky_keys).
    # If sticky keys are enabled, a key press will ensure that `#key` returns `KeyState::Pressed`
    # the next time it is called even if the key had been released before the call.
    # This is useful when you are only interested in whether keys have been pressed
    # but not when or in which order.
    #
    # Whenever you poll state (via `#key`),
    # you risk missing the state change you are looking for.
    # If a pressed key is released again before you poll its state,
    # you will have missed the key press.
    # The recommended solution for this is to use `#on_key`,
    # but there is also the sticky key input mode.
    #
    # Possible errors that could be raised are: `NotInitializedError` and `PlatformError`.
    #
    # See also: `#sticky?`
    def sticky=(flag)
      value = bool_to_int(flag)
      checked { LibGLFW.set_input_mode(@pointer, LibGLFW::InputMode::StickyKeys, value) }
    end

    # Indicates whether lock key modifier flags are enabled.
    # If enabled, callbacks that receive modifier bits
    # will also have the `ModifierKey::CapsLock` flag set
    # when the event was generated with Caps Lock on,
    # and the `ModifierKey::NumLock` flag when Num Lock was on.
    def lock_key_modifiers?
      value = expect_truthy { LibGLFW.get_input_mode(@pointer, LibGLFW::InputMode::LockKeyMods) }
      int_to_bool(value)
    end

    # Enables or disables lock key modifier flags.
    # If enabled, callbacks that receive modifier bits
    # will also have the `ModifierKey::CapsLock` flag set
    # when the event was generated with Caps Lock on,
    # and the `ModifierKey::NumLock` flag when Num Lock was on.
    def lock_key_modifiers=(flag)
      value = bool_to_int(flag)
      checked { LibGLFW.set_input_mode(@pointer, LibGLFW::InputMode::LockKeyMods, value) }
    end

    # Retrieves the underlying window pointer.
    def to_unsafe
      @pointer
    end

    # Retrieves the name of the specified printable key, encoded as UTF-8.
    # This is typically the character that key would produce without any modifier keys,
    # intended for displaying key bindings to the user.
    # For dead keys, it is typically the diacritic it would add to a character.
    #
    # **Do not use this method** for text input.
    # You will break text input for many languages even if it happens to work for yours.
    #
    # The printable keys are:
    # - `Key::Apostrohpe`
    # - `Key::Comma`
    # - `Key::Minus`
    # - `Key::Period`
    # - `Key::Slash`
    # - `Key::Semicolon`
    # - `Key::Equal`
    # - `Key::LeftBracket`
    # - `Key::RightBracket`
    # - `Key::Backslash`
    # - `Key::World1`
    # - `Key::World2`
    # - `Key::Num0` to `Key::Num9`
    # - `Key::A` to `Key::Z`
    # - `Key::KeyPad0` to `Key::KeyPad9`
    # - `Key::KeyPadDecimal`
    # - `Key::KeyPadDivide`
    # - `Key::KeyPadMultiply`
    # - `Key::KeyPadSubtract`
    # - `Key::KeyPadAdd`
    # - `Key::KeyPadEqual`
    #
    # Names for printable keys depend on keyboard layout,
    # while names for non-printable keys are the same across layouts
    # but depend on the application language
    # and should be localized along with other user interface text.
    #
    # Returns a string if a name is available for the specified *key*, nil otherwise.
    def self.key_name?(key : Key)
      raise ArgumentError.new("Key must be known") if key == Key::Unknown

      key_name?(key, 0)
    end

    # Retrieves the name of the specified printable key, encoded as UTF-8.
    # This is typically the character that key would produce without any modifier keys,
    # intended for displaying key bindings to the user.
    # For dead keys, it is typically the diacritic it would add to a character.
    #
    # **Do not use this method** for text input.
    # You will break text input for many languages even if it happens to work for yours.
    #
    # Names for printable keys depend on keyboard layout,
    # while names for non-printable keys are the same across layouts
    # but depend on the application language
    # and should be localized along with other user interface text.
    #
    # Returns a string if a name is available for the specified *scancode*, nil otherwise.
    def self.key_name?(scancode)
      key_name?(Key::Unknown, scancode)
    end

    # Retrieves the name of the specified printable key, encoded as UTF-8.
    #
    # If the *key* is `Key::Unknown`, the *scancode* is used to identify the key,
    # otherwise the *scancode* is ignored.
    # If you specify a non-printable key, or `Key::Unknown` and a *scancode* that maps to a non-printable key,
    # this method returns nil but does not raise an error.
    #
    # This behavior allows you to always pass in the arguments from the `#on_key` callback without modification.
    protected def self.key_name?(key : Key, scancode)
      chars = expect_truthy { LibGLFW.get_key_name(key.native, scancode) }
      chars ? String.new(chars) : nil
    end

    # Retrieves the platform-specific scancode of the specified key.
    #
    # If the *key* is `Key::Unknown` or does not exist on the keyboard this method will return nil.
    def self.scancode?(key)
      scancode = expect_not(-1) { LibGLFW.get_key_scancode(key) }
      scancode == -1 ? nil : scancode
    end

    # Retrieves the platform-specific scancode of the specified key.
    #
    # If the *key* is `Key::Unknown` or does not exist on the keyboard this method will raise `NilAssertionError`.
    def self.scancode(key)
      scancode?(key).not_nil!
    end
  end
end
