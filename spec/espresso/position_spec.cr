require "../spec_helper"

Spectator.describe Espresso::Position do
  let(x) { 42 }
  let(y) { 24 }
  subject(position) { described_class.new(x, y) }

  it "stores the x-coordinate" do
    expect(position.x).to eq(x)
  end

  it "stores the y-coordinate" do
    expect(position.y).to eq(y)
  end

  describe "#to_s" do
    subject { position.to_s }

    it "is formatted correctly" do
      is_expected.to match(/^\(\d+, \d+\)$/)
    end

    it "contains the x-coordinate" do
      is_expected.to contain("#{x}, ")
    end

    it "contains the y-coordinate" do
      is_expected.to contain(", #{y}")
    end
  end
end
