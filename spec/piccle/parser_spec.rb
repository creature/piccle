require "spec_helper"
require "logger"

describe Piccle::Parser do
  subject { Piccle::Parser.new }
  let(:photo_1) { Piccle::Photo.from_file('spec/example_images/elephant-1822636_1920.jpg') }
  let(:photo_1_md5) { "3c3f979ee5f2bf344cb246fcad52d2fe" }
  let(:photo_2) { Piccle::Photo.from_file('spec/example_images/kingfisher-1905255_1920.jpg') }

  it "has no photos by default" do
    expect(subject).to be_empty
  end

  it "Pulls photos out into a hash" do
    subject.parse(photo_1)

    expect(subject.data).to be_a Hash
    expect(subject.data).to have_key :photos
    expect(subject.data[:photos]).not_to be_empty
    expect(subject.data[:photos]).to have_key photo_1_md5
  end

  it "extracts common data into the data array" do
    subject.parse(photo_1)

    %i(title description taken_at).each do |attr|
      expect(subject.data[:photos][photo_1_md5]).to have_key attr
    end
  end

  context "with a date stream" do
    before(:each) { subject.add_stream(Piccle::Streams::DateStream) }

    it "allows streams to be registered" do
      expect(subject.streams.length).to eq 1
    end

    it "adds extra data to the data array" do
      subject.parse(photo_1)

      stream_keys = %i(by-year by_month by_day)
      stream_keys.each do |key|
        expect(subject.data).to have_key key
      end
    end

    it "can cross_link photos" do
      subject.parse(photo_1)

      result = subject.links_for(photo_1_md5)
      expect(result).to be_instance_of Array
    end
  end
end
