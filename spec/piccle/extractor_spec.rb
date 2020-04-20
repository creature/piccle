require "spec_helper"

describe Piccle::Extractor do
  let(:parser) { Piccle::Parser.new }
  let(:photo_1) { Piccle::Photo.from_file('spec/example_images/elephant-1822636_1920.jpg') }
  subject { Piccle::Extractor.new(parser) }

  before(:each) do
    puts "Registering streams"
    parser.add_stream(Piccle::Streams::DateStream)
    parser.parse(photo_1)
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
end
