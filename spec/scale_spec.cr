require "./spec_helper"

Spectator.describe Espresso::Scale do
  let(x) { 2.0f32 }
  let(y) { 0.5f32 }
  subject(scale) { described_class.new(x, y) }

  it "stores the x amount" do
    expect(scale.x).to eq(x)
  end

  it "stores the y amount" do
    expect(scale.y).to eq(y)
  end

  describe "#to_s" do
    subject { scale.to_s }

    it "is formatted correctly" do
      is_expected.to match(/^\(\d+(\.\d+)?x, \d+(\.\d+)?x\)$/)
    end

    it "contains the x-coordinate" do
      is_expected.to contain("#{x}x, ")
    end

    it "contains the y-coordinate" do
      is_expected.to contain(", #{y}x")
    end
  end
end
