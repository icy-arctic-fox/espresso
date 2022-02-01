# Espresso

Lightweight wrapper around GLFW for Crystal.
Provides an OOP and "Crystal-like" interface to GLFW.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  espresso:
    gitlab: arctic-fox/espresso
```

2. Run `shards install`

3. Make sure you have GLFW 3.3 installed to your system.

### Install GLFW 3.3

Download the packages from [GLFW's website](https://www.glfw.org/download.html)
or compile from source.

If you're on Linux or MacOS, and want to build from source,
run `./install-glfw.sh` with sudo in this directory.
You will need [CMake](https://cmake.org/), git, and a C compiler installed.
You will probably also need Xorg development libraries.
On Ubuntu, those can be installed with `apt-get install xorg-dev`.

## Usage

Here's an example of displaying a window:

```crystal
require "espresso"

Espresso.run do
  Espresso::Window.open(800, 600, "Espresso") do |window|
    until window.closing?
      window.swap_buffers
      Espresso::Window.poll_events
    end
  end
end
```

GLFW must be initialized before most of its operations can be performed.
The best way to do this is by using
[`Espresso.run`](https://arctic-fox.gitlab.io/espresso/Espresso.html#run%28joystick_hat_buttons%3ABool%3F%3Dnil%2Ccocoa_chdir_resources%3ABool%3F%3Dnil%2Ccocoa_menubar%3ABool%3F%3Dnil%2C%26block%29-instance-method),
like so:

```crystal
Espresso.run do
  # Use GLFW here.
end
```

GLFW will be initialized before calling the block,
and terminated after the block is done.

Alternatively,
[`Espresso.init`](https://arctic-fox.gitlab.io/espresso/Espresso.html#init%28joystick_hat_buttons%3ABool%3F%3Dnil%2Ccocoa_chdir_resources%3ABool%3F%3Dnil%2Ccocoa_menubar%3ABool%3F%3Dnil%29%3ANil-instance-method)
and
[`Espresso.terminate`](https://arctic-fox.gitlab.io/espresso/Espresso.html#terminate%3ANil-instance-method)
can be used,
but you are responsible for ensuring they get called correctly.

Most of the functions from GLFW are wrapped by instance methods.
They are placed into a type that corresponds with their purpose.

For example, functions in GLFW that would normally take a monitor pointer as the first argument,
are now instances methods in a [`Monitor`](https://arctic-fox.gitlab.io/espresso/Espresso/Monitor.html) struct.

```crystal
monitor = Monitor.primary
puts monitor.name
```

is equivalent to the C code:

```c
GLFWmonitor *monitor = glfwGetPrimaryMonitor();
printf("%s\n", glfwGetMonitorName(monitor));
```

Additionally, the pointer is the only instance variable in the struct.

When compiled, this indirection is removed, so it's as fast as calling the method itself.
This provides a friendlier object-oriented approach without sacrificing speed.

### Windows

Windows are the biggest part of GLFW.
As such, there is a lot of functionality put behind them.
The easiest way to get a window in Espresso, is to call
[`Window.open`](https://arctic-fox.gitlab.io/espresso/Espresso/Window.html#open%28width%3AInt32%2Cheight%3AInt32%2Ctitle%3AString%2C%26block%29-class-method)
or
[`Window.full_screen`](https://arctic-fox.gitlab.io/espresso/Espresso/Window.html#full_screen%28title%3AString%2C%26block%29-class-method).
A block can be provided to these methods.
When present, Espresso will automatically make the window's context current and ensure proper cleanup of its resources.
Without a block, use
[`Window.new`](https://arctic-fox.gitlab.io/espresso/Espresso/Window.html#new%28width%3AInt32%2Cheight%3AInt32%2Ctitle%3AString%29-class-method)
or
[`Window.full_screen`](https://arctic-fox.gitlab.io/espresso/Espresso/Window.html#full_screen%28title%3AString%29-class-method).
These methods simply return a [`Window`](https://arctic-fox.gitlab.io/espresso/Espresso/Window.html) instance.

```crystal
# For windowed mode.
Espresso::Window.open(800, 600, "Espresso") do
  # Use the window here.
end

# For full-screen mode.
Espresso::Window.full_screen("Espresso") do
  # Use the window here.
end

# Alternatively, without the block form:
window = Espresso::Window.new(800, 600, "Espresso")
# or for full screen...
window = Espresso::Window.full_screen("Espresso")
# Make sure to set the context and destroy when done.
window.current!
window.destroy!
```

You may want to customize the window before creating it.
To do so, use [`WindowBuilder`](https://arctic-fox.gitlab.io/espresso/Espresso/WindowBuilder.html).
Use one of the `build_*` methods to create the window.

```crystal
builder = Espresso::WindowBuilder.new
builder.context_version(3, 3)
builder.resizable = false
window = builder.build(800, 600, "Espresso")
```

### Input

Most input types are tied to GLFW windows.
To access them, use
[`Window#mouse`](https://arctic-fox.gitlab.io/espresso/Espresso/Window.html#mouse-instance-method) and
[`Window#keyboard`](https://arctic-fox.gitlab.io/espresso/Espresso/Window.html#keyboard-instance-method).
For joystick input, use the [`Joystick`](https://arctic-fox.gitlab.io/espresso/Espresso/Joystick.html)
type, since it isn't tied to a window.

### Events

If you're familiar with how GLFW handles events,
you'll know that it uses callbacks like `glfwSetKeyCallback`.
However, Espresso changes how event callbacks are exposed.
Instead of setting a single callback for an event, Espresso allows setting multiple.
Additionally, native blocks and closures can be used (which isn't allowed with normal C callbacks).
Registering an event listener in Espresso is as easy as passing a  block to any `#on_*` method.

```crystal
window.keyboard.on_key do |event|
  # The `event` argument contains all event information.
  puts "Key #{event.pressed? ? "pressed" : "released"} #{event.key}"
end
```

To remove a callback at a later point in time, call the corresponding `#remove_*_listener`.
The `#on_*` method returns a proc, which needs to be passed to the `#remove_*_listener`.
Removing a listener is optional - they will automatically be cleaned up when the resource they're tied to is destroyed.

```crystal
proc = window.keyboard.on_key do |event|
  # ...
end

# ...

window.keyboard.remove_key_listener(proc)
```

Events are typically tied to an instance, but some events aren't (or can't be) tied to an instance.
Those exceptions are the `#on_connect` events for monitors and joysticks.
Listeners can be set up for disconnect of all monitors and joysticks, or just one instance.

```crystal
Espresso::Monitor.on_connect do |monitor|
  if event.connected?
    # New monitor connected.
  else
    # Monitor disconnected.
  end
end

# The instance-specific variant.
# This is only invoked for the monitor instance it is associated with.
monitor = Espresso::Monitor.primary
monitor.on_disconnect do |monitor|
  # Called when the primary monitor is disconnected.
end
```

### Errors

GLFW errors have been changed to exceptions in Espresso.
All calls that could possibly cause an error are wrapped and checks handled by Espresso.
If GLFW reports an error, it will be raised from within Espresso (as to not break out of the stack).
All errors inherit from a base [`GLFWError`](https://arctic-fox.gitlab.io/espresso/Espresso/GLFWError.html) class.

```crystal
begin
  window.resize(800, 600)
rescue ex : Espresso::PlatformError
  # Handle error.
end
```

## Documentation

Documentation is automatically generated and published [here](https://arctic-fox.gitlab.io/espresso/).
The primary pages you will be interested in are:

- [Espresso](https://arctic-fox.gitlab.io/espresso/Espresso.html)
- [Window](https://arctic-fox.gitlab.io/espresso/Espresso/Window.html)
- [WindowBuilder](https://arctic-fox.gitlab.io/espresso/Espresso/WindowBuilder.html)
- [Keyboard](https://arctic-fox.gitlab.io/espresso/Espresso/Keyboard.html)
- [Mouse](https://arctic-fox.gitlab.io/espresso/Espresso/Mouse.html)
- [Joystick](https://arctic-fox.gitlab.io/espresso/Espresso/Joystick.html)
- [Monitor](https://arctic-fox.gitlab.io/espresso/Espresso/Monitor.html)

## Development

[Ameba](https://github.com/veelenga/ameba) is used for linting.
The CI build ensures that proper formatting and style is applied.

A docker image is generated to run tests in.
It runs Ubuntu 18 and installs Crystal, GLFW, and everything else needed for simulating an environment.
Specs are run in the docker container as part of the CI build.
Due to the difficulty, writing tests is not required, but encouraged if it can be done.
Specs might not pass on your system, but should pass in the docker container.

## Contributing

1. Fork it (<https://gitlab.com/arctic-fox/espresso/forks/new>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Merge Request

## Contributors

- [Michael Miller](https://gitlab.com/arctic-fox) - creator and maintainer
