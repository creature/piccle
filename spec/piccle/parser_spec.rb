require "spec_helper"
require "logger"

describe Piccle::Parser do
  subject { Piccle::Parser.new }
  let(:photo_1) { Piccle::Photo.from_file('spec/example_images/elephant-1822636_1920.jpg') }
  let(:photo_2) { Piccle::Photo.from_file('spec/example_images/kingfisher-1905255_1920.jpg') }

  it "has no photos by default" do
    expect(subject).to be_empty
  end

  it "Pulls photos out into a hash" do
    subject.parse(photo_1)

    expect(subject.data).to be_a Hash
    expect(subject.data).to have_key :photos
    expect(subject.data[:photos]).not_to be_empty
  end
end
