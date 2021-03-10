# frozen_string_literal: true

require "gems_bond/fetchers/ruby_gems"

RSpec.describe GemsBond::Fetchers::RubyGems, api: true do
  subject(:ruby_gems) { described_class.new("rails") }

  describe "#start" do
    context "when name does not match a gem on RubyGems" do
      it "does not start" do
        invalid_name = "i-do-not-exist-on-ruby-gems"
        fetcher = described_class.new(invalid_name)
        fetcher.start
        expect(fetcher.started?).to eq false
      end
    end

    context "when name matches a gem on RubyGems" do
      it "starts" do
        ruby_gems.start
        expect(ruby_gems.started?).to eq true
      end
    end
  end

  it "handles RubyGems data", :aggregate_failures do
    fetcher = ruby_gems.tap(&:start)
    expect(fetcher.downloads_count).to be > 0
    expect(fetcher.versions).not_to be_empty
  end
end
