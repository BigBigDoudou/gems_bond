# frozen_string_literal: true

require "gems_bond/fetchers/github"

RSpec.describe GemsBond::Fetchers::Github, api: true do
  subject(:github) { described_class.new("https://github.com/rails/rails") }

  let(:with_valid_token) { GemsBond.configure { |config| config.github_token = ENV["GITHUB_TOKEN"] } }

  describe "#start" do
    context "when homepage does not match the GitHub repository URL pattern" do
      it "returns nil" do
        invalid_homepage = "foobar"
        expect(described_class.new(invalid_homepage).start).to be_nil
      end
    end

    context "when GitHub token is missing or invalid" do
      it "returns nil" do
        GemsBond.configure { |config| config.github_token = "not-a-token" }
        expect(described_class.new("https://github.com/rails/rails").start).to be_nil
      end
    end

    context "when repository does not exist or is private" do
      it "returns nil" do
        with_valid_token
        invalid_repository = "https://github.com/i-do-not/exist"
        expect(described_class.new(invalid_repository).start).to be_nil
      end
    end

    context "when all inputs are valid" do
      it "returns self" do
        with_valid_token
        expect(github.start).to eq github
      end
    end
  end

  it "handle GitHub data", :aggregate_failures do
    with_valid_token
    fetcher = github.start
    expect(fetcher.forks_count).to be > 0
    expect(fetcher.stars_count).to be > 0
    expect(fetcher.contributors_count).to be > 0
    expect(fetcher.open_issues_count).to be > 0
    expect(fetcher.last_commit_date).to be_an Date
  end
end
