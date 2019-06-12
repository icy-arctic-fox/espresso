require "./spec_helper"

Spectator.describe Espresso::Monitor do
  # XRandR information.
  let(xrandr) { XRandR.info }
  let(screen) { xrandr[:screen] }
  let(monitors) { xrandr[:monitors].select(&.connected) } # GLFW only reports connected monitors.

  # Monitor objects to inspect.
  subject(monitor) { described_class.primary }                       # SUT
  let(primary) { monitors.find(monitors.first, &.primary).not_nil! } # Source of truth

  around_each do |example|
    Espresso.run { example.call }
  end

  describe "#primary" do
    it "is the primary monitor" do
      return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.

      # Can't get IDs, so do the best we can to check if they appear to be the same.
      expect(subject.name).to eq(primary.name)
      expect(subject.position).to have_attributes(x: primary.x, y: primary.y)
      # expect(subject.size).to have_attributes(width: primary.width, height: primary.height)
    end
  end

  describe "#all" do
    it "has all monitors" do
      expect(Espresso::Monitor.all.size).to eq(monitors.size)
    end
  end

  describe "#position" do
    subject { monitor.position }

    it "has the correct values" do
      return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.

      is_expected.to have_attributes(x: primary.x, y: primary.y)
    end
  end

  describe "#size" do
    subject { monitor.size }

    it "has the correct values" do
      return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.

      is_expected.to have_attributes(width: primary.width, height: primary.height)
    end
  end

  describe "#physical_size" do
    subject { monitor.physical_size }

    it "has the correct values" do
      return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.

      is_expected.to have_attributes(width: primary.width_mm, height: primary.height_mm)
    end
  end

  describe "#name" do
    subject { monitor.name }

    it "has the correct value" do
      return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.

      is_expected.to eq(primary.name)
    end
  end

  describe "#video_modes" do
    subject { monitor.video_modes }

    it "has the expected video modes" do
      return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.
      expect(monitor.video_modes.size).to be_ge(primary.video_modes.size)
    end
  end

  it "can get and store user pointers" do
    return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.

    object = "foobar"
    pointer = Box.box(object)
    monitor.user_pointer = pointer
    expect(monitor.user_pointer).to eq(pointer)
    unboxed = Box(typeof(object)).unbox(monitor.user_pointer)
    expect(unboxed.object_id).to eq(object.object_id)
  end

  let(gamma_supported?) do
    if (monitor = Espresso::Monitor.primary?)
      begin
        monitor.gamma = 1.0
      rescue Espresso::PlatformError
        false
      end
    end
  end

  describe "#gamma=" do
    it "doesn't raise on valid gamma values" do
      return unless gamma_supported?

      expect { monitor.gamma = 2.2 }.to_not raise_error
    end

    it "raises on invalid gamma values" do
      expect { monitor.gamma = -1.0 }.to raise_error(ArgumentError, /gamma/)
    end
  end

  it "can get and set gamma ramps" do
    return unless gamma_supported?

    original_ramp = Espresso::GammaRamp.new
    monitor.gamma_ramp = original_ramp
    retrieved_ramp = monitor.gamma_ramp
    expect(retrieved_ramp).to have_attributes(size: original_ramp.size,
      red: original_ramp.red, green: original_ramp.green, blue: original_ramp.blue)
  end

  describe "#to_s" do
    subject { monitor.to_s }

    it "contains the name" do
      is_expected.to contain(monitor.name)
    end
  end
end
