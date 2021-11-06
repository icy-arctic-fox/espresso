require "../spec_helper"

Spectator.describe Espresso do
  let(major) { 3 }
  let(minor) { 3 }
  let(patch) { 0 }

  describe "#init" do
    it "doesn't raise" do
      expect { Espresso.init }.to_not raise_error
    end

    it "doesn't raise on re-initialization" do
      Espresso.init
      expect { Espresso.init }.to_not raise_error
    end
  end

  describe "#run" do
    it "doesn't raise" do
      expect { Espresso.run { } }.to_not raise_error
    end

    it "doesn't raise on re-initialization" do
      expect { Espresso.run { Espresso.run { } } }.to_not raise_error
    end
  end

  describe "#version" do
    subject { Espresso.version }

    it { is_expected.to have_attributes(major: major, minor: minor) }
  end

  describe "#compiled_version" do
    subject { Espresso.compiled_version }

    it { is_expected.to have_attributes(major: major, minor: minor) }
  end

  describe "#runtime_version" do
    subject { Espresso.runtime_version }

    it { is_expected.to have_attributes(major: major, minor: minor) }
  end

  describe "#version_string" do
    subject { Espresso.version_string }

    it "contains the version" do
      is_expected.to contain(Espresso.version.to_s)
    end
  end
end
