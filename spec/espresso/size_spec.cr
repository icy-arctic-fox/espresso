require "../spec_helper"

Spectator.describe Espresso::Size do
  let(width) { 42 }
  let(height) { 24 }
  subject(size) { described_class.new(width, height) }

  it "stores the width" do
    expect(size.width).to eq(width)
  end

  it "stores the height" do
    expect(size.height).to eq(height)
  end

  describe "#to_s" do
    subject { size.to_s }

    it "is formatted correctly" do
      is_expected.to match(/^\d+x\d+$/)
    end

    it "contains the width" do
      is_expected.to contain("#{width}x")
    end

    it "contains the height" do
      is_expected.to contain("x#{height}")
    end
  end
end
