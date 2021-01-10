require "spec_helper"

describe Piccle::Streams::LocationStream do
  let(:sahara_photo) { Piccle::Photo.from_file("spec/example_images/sahara-3436700_1920.jpg") }
  let(:mesa_photo) { Piccle::Photo.from_file("spec/example_images/usa-5009894_1920.jpg") }

  describe "#metadata_for" do
    it "returns nothing when there is no location info" do
      expect(subject.metadata_for(sahara_photo)).to be_empty
    end
  end
end
