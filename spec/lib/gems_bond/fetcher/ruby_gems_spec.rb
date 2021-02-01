# frozen_string_literal: true

require "gems_bond/fetcher/ruby_gems"

RSpec.describe GemsBond::Fetcher::RubyGems do
  subject(:ruby_gems) { described_class.new("dotenv") }

  before do
    GemsBond.configure { |config| config.github_token = ENV["GITHUB_TOKEN"] }
  end

  describe "#source" do
    it "returns ruby gems" do
      expect(ruby_gems.source).to eq "ruby gems"
    end
  end

  describe "#start" do
    context "when name does not match a gem on RubyGems" do
      it "returns nil" do
        invalid_name = "i-do-not-exist-on-ruby-gems"
        expect(described_class.new(invalid_name).start).to be_nil
      end
    end

    context "when name matches a gem on RubyGems" do
      it "returns self" do
        expect(ruby_gems.start).to eq ruby_gems
      end
    end
  end

  context "when ruby_gems is started" do
    describe "downloads_count" do
      it "returns the number of downloads" do
        expect(ruby_gems.start.downloads_count).to be_an Integer
      end
    end

    describe "versions" do
      it "returns the list of versions" do
        expect(ruby_gems.start.versions).to be_an Array
      end
    end
  end
end
