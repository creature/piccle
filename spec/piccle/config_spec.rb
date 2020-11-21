require "spec_helper"

describe Piccle::Config do
  let(:relative_params) do
    { :working_directory => "/Users/alex/Code/Personal/piccle", :home_directory => "/Users/alex",
      :"image-dir" => "custom_images", :"output-dir" => "custom_generated" }
  end
  let(:absolute_params) do
    { :working_directory => "/Users/alex/Code/Personal/piccle", :home_directory => "/Users/alex",
      :"image-dir" => "/tmp/custom_images", :"output-dir" => "/tmp/custom_generated" }
  end
  let(:bare_params) do
    # We always set working directory and home directory.
    { :working_directory => "/Users/alex/Code/Personal/piccle", :home_directory => "/Users/alex" }
  end
  let(:alice_params) do
    {}
  end
  let(:bare_config) { Piccle::Config.new(bare_params) }
  let(:relative_config) { Piccle::Config.new(relative_params) }
  let(:absolute_config) { Piccle::Config.new(absolute_params) }

  it "exists" do
    expect(Piccle::Config).to be
  end

  describe "#output_dir" do
    it "defaults to $CWD/generated" do
      expect(bare_config.output_dir).to eq("/Users/alex/Code/Personal/piccle/generated")
    end

    it "generates relative pathnames if given a relative path" do
      expect(relative_config.output_dir).to eq("/Users/alex/Code/Personal/piccle/custom_generated")
    end

    it "respects absolute pathnames" do
      expect(absolute_config.output_dir).to eq("/tmp/custom_generated")
    end
  end

  describe "#images_dir" do
    it "defaults to $CWD/images" do
      expect(bare_config.images_dir).to eq("/Users/alex/Code/Personal/piccle/images")
    end

    it "generates relative pathnames if given a relative path" do
      expect(relative_config.images_dir).to eq("/Users/alex/Code/Personal/piccle/custom_images")
    end

    it "respects absolute pathnames" do
      expect(absolute_config.images_dir).to eq("/tmp/custom_images")
    end
  end

  describe "#atom?" do
    it "generates Atom feeds when in debug mode" do
      config = Piccle::Config.new(debug: true)
      expect(config.atom?).to be_truthy
    end

    it "does not generate Atom feeds when no URL is set" do
      config = Piccle::Config.new(debug: false)
      expect(config.atom?).to be_falsy
    end

    it "generates Atom feeds when a URL is set" do
      config = Piccle::Config.new(debug: false, url: "https://alexpounds.com")
      expect(config.atom?).to be_truthy
    end
  end

  describe "#author" do
    it "defaults to an anonymous string" do
      expect(bare_config.author).to eq("An Anonymous Photographer")
    end

    it "uses a value specified in a config file" do
      config = Piccle::Config.new(alice_params.merge(config: Bundler.root.join("spec", "example_configs", "alice.yaml")))
      expect(config.author).to eq("Alice")
    end

    it "uses a value specified in parameters over that in the config file" do
      config = Piccle::Config.new(alice_params.merge(author: "Bob Bloggs"))
      expect(config.author).to eq("Bob Bloggs")
    end
  end
end
