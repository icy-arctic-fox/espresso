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

      expect(subject.x).to eq(primary.x)
      expect(subject.y).to eq(primary.y)
    end
  end

  describe "#size" do
    subject { monitor.size }

    pending "has the correct values" do
      return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.

      expect(subject.width).to eq(primary.width)
      expect(subject.height).to eq(primary.height)
    end
  end

  describe "#physical_size" do
    subject { monitor.physical_size }

    it "has the correct values" do
      return unless Espresso::Monitor.primary? # Skip test if there's no primary monitor.

      expect(subject.width).to eq(primary.width_mm)
      expect(subject.height).to eq(primary.height_mm)
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
end
