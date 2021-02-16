# frozen_string_literal: true

require "gems_bond/fetcher/ruby_gems"

RSpec.describe GemsBond::Fetcher::RubyGems, api: true do
  subject(:ruby_gems) { described_class.new("rails") }

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

  it "handle RubyGems data", :aggregate_failures do
    expect(ruby_gems.start.downloads_count).to be > 0
    expect(ruby_gems.start.versions).not_to be_empty
  end
end
