require "./spec_helper"

Spectator.describe Espresso::GammaRamp do
  it "creates arrays of expected length" do
    ramp = described_class.new(128)
    expect(ramp.red.size).to eq(128)
    expect(ramp.green.size).to eq(128)
    expect(ramp.blue.size).to eq(128)
  end

  it "stores the size" do
    ramp = described_class.new(64)
    expect(ramp.size).to eq(64)
  end

  describe "#to_unsafe" do
    before_each do
      # Populate with "random" values.
      # The hash of the index is used as the value.
      subject.size.times do |index|
        subject.red[index] = (index + 1).hash.to_u16
        subject.green[index] = (index + 2).hash.to_u16
        subject.blue[index] = (index + 3).hash.to_u16
      end
    end

    it "produces a corresponding GLFW struct" do
      ramp = subject.to_unsafe
      size = ramp.size.to_i
      expect(size).to eq(subject.size)

      red = Slice.new(ramp.red, size)
      expect(red).to eq(subject.red)

      green = Slice.new(ramp.green, size)
      expect(green).to eq(subject.green)

      blue = Slice.new(ramp.blue, size)
      expect(blue).to eq(subject.blue)
    end
  end
end
