# frozen_string_literal: true

require "gems_bond/fetcher/github"

RSpec.describe GemsBond::Fetcher::Github do
  subject(:github) { described_class.new("https://github.com/BigBigDoudou/github_api_stub") }

  before do
    GemsBond.configure { |config| config.github_token = ENV["GITHUB_TOKEN"] }
  end

  describe "#source" do
    it "returns github" do
      expect(github.source).to eq "github"
    end
  end

  describe "#start" do
    context "when homepage does not match the GitHub repository URL pattern" do
      it "returns nil" do
        invalid_homepage = "foobar"
        expect(described_class.new(invalid_homepage).start).to be_nil
      end
    end

    context "when GitHub token is missing or invalid" do
      it "returns nil" do
        GemsBond.configure { |config| config.github_token = "foobar" }
        expect(described_class.new("https://github.com/rails/rails").start).to be_nil
      end
    end

    context "when repository does not exist or is private" do
      it "returns nil" do
        invalid_repository = "https://github.com/i-do-not/exist"
        expect(described_class.new(invalid_repository).start).to be_nil
      end
    end

    context "when all inputs are valid" do
      it "returns self" do
        expect(github.start).to eq github
      end
    end
  end

  context "when github is started" do
    describe "forks_count" do
      it "returns the number of forks" do
        expect(github.start.forks_count).to be_an Integer
      end
    end

    describe "stars_count" do
      it "returns the number of stars" do
        expect(github.start.stars_count).to be_an Integer
      end
    end

    describe "contributors_count" do
      it "returns the number of contributors" do
        expect(github.start.contributors_count).to be_an Integer
      end
    end

    describe "open_issues_count" do
      it "returns the number of open_issues" do
        expect(github.start.open_issues_count).to be_an Integer
      end
    end

    describe "last_commit_date" do
      it "returns the date of the last commit" do
        expect(github.start.last_commit_date).to be_an Date
      end
    end

    describe "lib_size" do
      it "returns an estimated size - in lines - of the lib directory" do
        skip "unused method / performance issues due to recursivity"
        expect(github.start.lib_size).to be_an Integer
      end
    end
  end
end
