require "spec_helper"

describe Piccle::TemplateHelpers do
  subject { Piccle::TemplateHelpers }

  describe ".include_prefix" do
    it "returns an empty string when there is no selector" do
      expect(subject.include_prefix([])).to eq("")
    end

    it "returns a single level with one item" do
      expect(subject.include_prefix(["one"])).to eq("../")
    end

    it "returns two levels with two items" do
      expect(subject.include_prefix(["one", "two"])).to eq("../../")
    end
  end
end
