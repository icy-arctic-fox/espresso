require "./spec_helper"

Spectator.describe Espresso::Bounds do
  let(x) { 5 }
  let(y) { 7 }
  let(width) { 800 }
  let(height) { 600 }
  subject(bounds) { described_class.new(x, y, width, height) }

  it "stores the x position" do
    expect(bounds.x).to eq(x)
  end

  it "stores the y position" do
    expect(bounds.y).to eq(y)
  end

  it "stores the width" do
    expect(bounds.width).to eq(width)
  end

  it "stores the height" do
    expect(bounds.height).to eq(height)
  end

  it "calculates the right side" do
    expect(bounds.right).to eq(x + width)
  end

  it "calculates the bottom side" do
    expect(bounds.bottom).to eq(y + height)
  end

  it "uses x for the left side" do
    expect(bounds.left).to eq(x)
  end

  it "uses y for the top side" do
    expect(bounds.top).to eq(y)
  end
end
