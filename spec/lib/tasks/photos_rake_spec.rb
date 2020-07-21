require "json"
require "spec_helper"

describe "photos:update_locations" do
  include_context "rake"

  describe "#extract_field" do
    context "with an API response for Turkey" do
      let(:data) { JSON.parse(File.read("spec/example_api_responses/coordinates2politics_turkey.json")) }

      it "returns the correct country" do
        expect(subject.send(:extract_field, "country", data)).to eq("Turkey")
      end

      it "returns the correct 'state'" do
        expect(subject.send(:extract_field, "state", data)).to eq("Istanbul")
      end
    end
  end
end
