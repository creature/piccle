require "spec_helper"

describe Piccle::Streams::DateStream do
  subject { Piccle::Streams::DateStream.new }

  describe "#order" do
    it "reorders years as expected" do
      start = { "by-date" => { "2017" => {}, "2010" => {}, "2002" => {}} }
      result = subject.order(start)

      expect(result).to eq("by-date" => { "2002" => {}, "2010" => {}, "2017" => {}})
    end

    it "reorders months as expected" do
      start = { "by-date" => { "2010" => { "11" => {}, "9" => {}, "2" => {}}}}
      result = subject.order(start)

      expect(result).to eq("by-date" => { "2010" => { "2" => {}, "9" => {}, "11" => {}}})
    end
  end
end
