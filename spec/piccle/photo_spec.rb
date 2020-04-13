require "spec_helper"

describe Piccle::Photo do
  let(:photo_1) { Piccle::Photo.from_file('spec/example_images/elephant-1822636_1920.jpg') }
  let(:photo_1_md5) { "3c3f979ee5f2bf344cb246fcad52d2fe" }
  let(:photo_2) { Piccle::Photo.from_file('spec/example_images/kingfisher-1905255_1920.jpg') }
  let(:photo_2_md5) { "8928d9d8019213a1be5718f9a197fead" }

  it "exists" do
    expect(Piccle::Photo).to be
  end

  describe "photo orientation" do
    context "with photo 1" do
      subject { photo_1 }
      it { is_expected.to be_landscape }
      it { is_expected.not_to be_portrait }
      it { is_expected.not_to be_square }
    end
  end
end
