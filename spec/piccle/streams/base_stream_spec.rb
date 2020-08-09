require "spec_helper"

describe Piccle::Streams::BaseStream do
  subject { Piccle::Streams::BaseStream.new }

  describe "#slugify" do
    it "lower-cases names" do
      expect(subject.send(:slugify, "HELLO")).to eq("hello")
      expect(subject.send(:slugify, "wHaTiStHiS")).to eq("whatisthis")
    end

    it "replaces spaces with dashes" do
      expect(subject.send(:slugify, "two words")).to eq("two-words")
      expect(subject.send(:slugify, "more than two words")).to eq("more-than-two-words")
    end

    it "replaces other symbols with dashes" do
      expect(subject.send(:slugify, "Aaahh!!! Real Monsters! Fan Convention")).to eq("aaahh-real-monsters-fan-convention")
      expect(subject.send(:slugify, "A$AP Mob Concert")).to eq("a-ap-mob-concert")
    end

    it "trims trailing dashes" do
      expect(subject.send(:slugify, "Exciting!")).to eq("exciting")
    end

    it "overall works as expected" do
      expect(subject.send(:slugify, "UK Trip 2019")).to eq("uk-trip-2019")
      expect(subject.send(:slugify, "Co-op photo club portraits")).to eq("co-op-photo-club-portraits")
    end
  end
end
