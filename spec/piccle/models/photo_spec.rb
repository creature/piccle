require "spec_helper"

describe Piccle::Photo do
  let(:elephant_photo_path) { "spec/example_images/elephant-1822636_1920.jpg" }
  let(:elephant_photo_md5) { "3c3f979ee5f2bf344cb246fcad52d2fe" }
  let(:elephant_photo) { Piccle::Photo.from_file(elephant_photo_path) }
  let(:kingfisher_photo_path) { "spec/example_images/kingfisher-1905255_1920.jpg" }
  let(:kingfisher_photo_md5) { "8928d9d8019213a1be5718f9a197fead" }
  let(:kingfisher_photo) { Piccle::Photo.from_file(kingfisher_photo_path) }
  let(:sahara_photo_path) { "spec/example_images/sahara-3436700_1920.jpg" }
  let(:sahara_photo) { Piccle::Photo.from_file(sahara_photo_path) }

  it "exists" do
    expect(Piccle::Photo).to be
  end

  describe "photo orientation" do
    context "with photo 1" do
      subject { elephant_photo }
      it { is_expected.to be_landscape }
      it { is_expected.not_to be_portrait }
      it { is_expected.not_to be_square }
    end
  end

  describe "class methods" do
    describe ".data_hash" do
      subject { Piccle::Photo.data_hash(elephant_photo_path) }

      it "extracts data about the image" do
        expect(subject[:md5]).to eq(elephant_photo_md5)
        expect(subject[:width]).to eq(1920)
        expect(subject[:height]).to eq(1309)
      end

      it "extracts camera metadata about the image" do
        expect(subject[:camera_name]).to eq("NIKON D810")
        expect(subject[:iso]).to eq(320)
      end
    end

    describe ".earliest_photo_year" do
      it "returns the earliest year of all the photos in the database" do
        [elephant_photo, kingfisher_photo, sahara_photo]
        expect(Piccle::Photo.earliest_photo_year).to eq(2014)
      end
    end

    describe ".latest_photo_year" do
      it "returns the latest year of all photos in the database" do
        [elephant_photo, kingfisher_photo, sahara_photo]
        expect(Piccle::Photo.latest_photo_year).to eq(2017)
      end
    end
  end

  describe "instance methods" do
    describe "#geocoded?" do
      it "returns false for photos with no geographic info" do
        expect(elephant_photo).not_to be_geocoded
      end

      it "returns true if a photo has a latitude and longitude"
      it "returns true if a photo has any EXIF info for the city, state, or country"
    end

    describe "#generate_keywords" do
      it "does not create anything when a photo has no tags" do
        expect { elephant_photo.generate_keywords }.not_to change { Piccle::Keyword.count }
      end

      it "creates 3 keywords for an image with 3 EXIF tags" do
        expect { sahara_photo.generate_keywords }.to change { Piccle::Keyword.count }.by(3)
      end
    end
  end
end
