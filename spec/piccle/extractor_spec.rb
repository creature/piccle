require "spec_helper"

describe Piccle::Extractor do
  let(:parser) { Piccle::Parser.new }
  let(:photo_1) { Piccle::Photo.from_file('spec/example_images/elephant-1822636_1920.jpg') } # 2015
  let(:photo_2) { Piccle::Photo.from_file('spec/example_images/kingfisher-1905255_1920.jpg') } # 2014
  let(:photo_3) { Piccle::Photo.from_file('spec/example_images/spring-bird-2295431_1920.jpg') } # 2017
  subject { Piccle::Extractor.new(parser) }

  before(:each) do
    parser.add_stream(Piccle::Streams::DateStream)
    parser.parse(photo_1)
    parser.parse(photo_2)
    parser.parse(photo_3)
    parser.order
  end

  describe "#breadcrumbs_for" do
    it "returns an empty array, given an empty array" do
      expect(subject.breadcrumbs_for([])).to be_empty
    end

    it "returns just one element, without a link, when given one element" do
      expect(subject.breadcrumbs_for(["by-date"])).to eq([{ friendly_name: "By Date" }])
    end

    it "returns two elements, with a link, when given two elements" do
      expected = [{ friendly_name: "By Date" }, { friendly_name: "2015", link: "by-date/2015/index.html" }]
      expect(subject.breadcrumbs_for(["by-date", "2015"])).to eq(expected)
    end
  end

  describe "#prev_link" do
    it "returns nil with the first photo" do
      expect(subject.prev_link(photo_3.md5)).to be_nil
    end

    it "returns the first photo's link when passed the second" do
      expect(subject.prev_link(photo_1.md5)).to eq("#{photo_3.md5}.html")
    end

    it "returns the second photo's link when passed the third" do
      expect(subject.prev_link(photo_2.md5)).to eq("#{photo_1.md5}.html")
    end
  end
end
