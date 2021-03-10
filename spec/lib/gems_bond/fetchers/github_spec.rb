# frozen_string_literal: true

require "gems_bond/fetchers/github"

RSpec.describe GemsBond::Fetchers::Github, api: true do
  subject(:github) { described_class.new("https://github.com/rails/rails") }

  let(:with_valid_token) { GemsBond.configure { |config| config.github_token = ENV["GITHUB_TOKEN"] } }

  describe "#start" do
    context "when homepage does not match the GitHub repository URL pattern" do
      it "does not start" do
        invalid_homepage = "foobar"
        fetcher = described_class.new(invalid_homepage)
        fetcher.start
        expect(fetcher.started?).to eq false
      end
    end

    context "when GitHub token is missing or invalid" do
      it "does not start" do
        GemsBond.configure { |config| config.github_token = "not-a-token" }
        fetcher = described_class.new("https://github.com/rails/rails")
        fetcher.start
        expect(fetcher.started?).to eq false
      end
    end

    context "when repository does not exist or is private" do
      it "does not start" do
        with_valid_token
        invalid_repository = "https://github.com/i-do-not/exist"
        fetcher = described_class.new(invalid_repository)
        fetcher.start
        expect(fetcher.started?).to eq false
      end
    end

    context "when all inputs are valid" do
      it "starts" do
        with_valid_token
        github.start
        expect(github.started?).to eq true
      end
    end
  end

  it "handles GitHub data", :aggregate_failures do
    with_valid_token
    fetcher = github.tap(&:start)
    expect(fetcher.forks_count).to be > 0
    expect(fetcher.stars_count).to be > 0
    expect(fetcher.contributors_count).to be > 0
    expect(fetcher.open_issues_count).to be > 0
    expect(fetcher.last_commit_date).to be_an Date
  end
end
