require "spec_helper"
require "logger"

describe Piccle::Parser do
  subject { Piccle::Parser.new }

  let(:photo_1) { Piccle::Photo.from_file('spec/example_images/elephant-1822636_1920.jpg') }
  let(:photo_1_md5) { "3c3f979ee5f2bf344cb246fcad52d2fe" }
  let(:photo_2) { Piccle::Photo.from_file('spec/example_images/kingfisher-1905255_1920.jpg') }
  let(:photo_2_md5) { "8928d9d8019213a1be5718f9a197fead" }
  let(:data) { subject.data }

  it "has no photos by default" do
    expect(subject).to be_empty
  end

  it "Pulls photos out into a hash" do
    subject.parse(photo_1)

    expect(data).to be_a Hash
    expect(data).to have_key :photos
    expect(data[:photos]).not_to be_empty
    expect(data[:photos]).to have_key photo_1_md5
  end

  it "extracts common data into the data array" do
    subject.parse(photo_1)

    %i(title description taken_at).each do |attr|
      expect(data[:photos][photo_1_md5]).to have_key attr
    end
  end

  context "with a date stream" do
    before(:each) { subject.add_stream(Piccle::Streams::DateStream) }

    it "allows streams to be registered" do
      expect(subject.streams.length).to eq 1
    end

    it "adds extra data to the data array" do
      subject.parse(photo_1)
      expect(data).to have_key "by-date"
      expect(data["by-date"]).to have_key "2015"
      expect(data["by-date"]["2015"]).to have_key "10"
    end

    it "can cross_link photos" do
      subject.parse(photo_1)

      result = subject.links_for(photo_1_md5)
      expect(result).to be_instance_of Array
    end

    it "extracts the expected data for a year" do
      subject.parse(photo_1)

      expect(data["by-date"]["2015"]).to have_key "10"
      expect(data["by-date"]["2015"]).to have_key :photos
      expect(data["by-date"]["2015"][:photos]).to eq [photo_1_md5]
    end

    it "extracts the expected data for a month" do
      subject.parse(photo_1)
      expect(data.dig("by-date", "2015", "10")).to have_key "23"
      expect(data.dig("by-date", "2015", "10")).to have_key :photos
    end

    it "parses and merges data for multiple photos" do
      subject.parse(photo_1)
      subject.parse(photo_2)

      expected_result = {
        "by-date" => {
          "2015" => {
            "10" => {
              "23" => { photos: [photo_1_md5] },
              :photos => [photo_1_md5]
            },
            :photos => [photo_1_md5]
          },
          "2014" => {
            "7" => {
              "16" => { photos: [photo_2_md5] },
              :photos => [photo_2_md5]
            },
            :photos => [photo_2_md5]
          }
        }
      }

      expect(data).to be >= expected_result
    end
  end

  context "#merge_into" do
    it "merges an array into an empty array correctly" do
      destination = {}
      source = { "foo" => {} }
      result = subject.send(:merge_into, destination, source)

      expect(result).to eq({ "foo" => {} })
    end

    it "merges array contents, if the key is called photos" do
      destination = { photos: ["foo", "bar"] }
      source = { photos: ["boat"] }
      result = subject.send(:merge_into, destination, source)
      expect(result).to eq({ photos: ["foo", "bar", "boat"] })
    end

    it "preserves extra keys in the two hashes" do
      source = { photos: ["a", "b"], another: "plastic" }
      destination = { photos: ["c", "d"], other: "whatever"}
      result = subject.send(:merge_into, destination, source)

      expect(result).to include(another: "plastic")
      expect(result).to include(other: "whatever")
      expect(result[:photos]).to match_array(%w(a b c d))
    end

    it "merges nested hashes fine" do
      source = {
        photos: [photo_1_md5],
        "by-date" => {
          "2015" => {
            "10" => {
              "23" => { photos: [photo_1_md5] },
              :photos => [photo_1_md5]
            },
            :photos => [photo_1_md5]
          }
        }
      }
      destination = {
        photos: [photo_2_md5],
        "by-date" => {
          "2015" => {
            "7" => {
              "16" => { photos: [photo_2_md5] },
              :photos => [photo_2_md5]
            },
            :photos => [photo_2_md5]
          }
        }
      }

      result = subject.send(:merge_into, destination, source)

      expect(result[:photos]).to match_array([photo_1_md5, photo_2_md5])
      expect(result["by-date"]).to have_key("2015")
      expect(result["by-date"]["2015"].keys).to contain_exactly("10", "7", :photos)
      expect(result["by-date"]["2015"][:photos]).to contain_exactly(photo_1_md5, photo_2_md5)
      expect(result["by-date"]["2015"]["10"][:photos]).to contain_exactly(photo_1_md5)
      expect(result["by-date"]["2015"]["7"][:photos]).to contain_exactly(photo_2_md5)
    end
  end
end
