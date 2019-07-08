# Espresso

Lightweight wrapper around GLFW for Crystal.
Provides an OOP and "Crystal-like" interface to GLFW.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  expresso:
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

### Windows

TODO: Provide examples for working with windows.

### Input

TODO: Provide examples for working with input.

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
