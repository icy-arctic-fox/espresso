require "../spec_helper"

Spectator.describe Espresso::VideoMode do
  # Some very strange monitor configuration.
  let(width) { 1920 }
  let(height) { 1080 }
  let(red) { 3 }
  let(green) { 4 }
  let(blue) { 5 }
  let(rate) { 120 }
  subject(video_mode) { described_class.new(width, height, red, green, blue, rate) }

  it "stores the width" do
    expect(video_mode.width).to eq(width)
  end

  it "stores the height" do
    expect(video_mode.height).to eq(height)
  end

  it "stores the red bit depth" do
    expect(video_mode.red).to eq(red)
  end

  it "stores the green bit depth" do
    expect(video_mode.green).to eq(green)
  end

  it "stores the blue bit depth" do
    expect(video_mode.blue).to eq(blue)
  end

  it "stores the refresh rate" do
    expect(video_mode.refresh_rate).to eq(rate)
  end

  describe "#size" do
    subject { video_mode.size }

    it "contains the correct width and height" do
      is_expected.to have_attributes(width: width, height: height)
    end
  end

  describe "#depth" do
    subject { video_mode.depth }

    it "is the sum of all color channels" do
      is_expected.to eq(red + green + blue)
    end
  end

  describe "#to_s" do
    subject { video_mode.to_s }

    it "is formatted correctly" do
      is_expected.to match(/^\d+x\d+x\d+@\d+Hz \(R\dG\dB\d\)$/)
    end

    it "contains the width" do
      is_expected.to start_with("#{width}x")
    end

    it "contains the height" do
      is_expected.to contain("x#{height}x")
    end

    it "contains the depth" do
      is_expected.to contain("x#{red + green + blue}@")
    end

    it "contains the refresh rate" do
      is_expected.to contain("@#{rate}Hz")
    end

    it "contains the red bit depth" do
      is_expected.to contain("R#{red}")
    end

    it "contains the green bit depth" do
      is_expected.to contain("G#{green}")
    end

    it "contains the blue bit depth" do
      is_expected.to contain("B#{blue}")
    end
  end
end
