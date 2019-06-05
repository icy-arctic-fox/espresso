require "./spec_helper"

Spectator.describe Espresso do
  let(major) { 3 }
  let(minor) { 3 }
  let(patch) { 0 }

  describe "#version" do
    subject { Espresso.version }

    it { is_expected.to have_attributes(major: major, minor: minor, patch: patch) }
  end

  describe "#compiled_version" do
    subject { Espresso.compiled_version }

    it { is_expected.to have_attributes(major: major, minor: minor, patch: patch) }
  end

  describe "#runtime_version" do
    subject { Espresso.runtime_version }

    it { is_expected.to have_attributes(major: major, minor: minor, patch: patch) }
  end

  describe "#version_string" do
    subject { Espresso.version_string }

    it "contains the version" do
      is_expected.to contain(Espresso.version.to_s)
    end
  end
end
