# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Screens::Savers::PreprocessedURI do
  subject(:saver) { described_class.new }

  include_context "with temporary directory"

  describe "#call" do
    let(:fixture_path) { SPEC_ROOT.join "support/fixtures/test.png" }
    let(:output_path) { temp_dir.join "test.png" }

    it "saves file" do
      saver.call fixture_path, output_path
      image = MiniMagick::Image.open output_path

      expect(image).to have_attributes(width: 1, height: 1, type: "PNG", exif: {})
    end

    it "saves URL" do
      saver.call "https://git-scm.com/images/logos/downloads/Git-Icon-1788C.png", output_path
      image = MiniMagick::Image.open output_path

      expect(image).to have_attributes(width: 383, height: 383, type: "PNG", exif: {})
    end

    it "answers image path" do
      expect(saver.call(fixture_path, output_path)).to be_success(output_path)
    end

    it "answers failure when image can't be processed" do
      client = class_double MiniMagick::Image
      allow(client).to receive(:open).and_raise(MiniMagick::Error, "Danger!")
      saver = described_class.new(client:)

      expect(saver.call("bogus", output_path)).to be_failure("Danger!")
    end
  end
end
