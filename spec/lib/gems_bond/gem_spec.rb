# frozen_string_literal: true

require "bundler"
require "gems_bond/gem"
require "gems_bond/fetcher/ruby_gems"
require "gems_bond/fetcher/github"

RSpec.describe GemsBond::Gem do
  subject(:gem) { described_class.new(dependency) }

  let(:dependency) { Object.new }
  let(:to_spec) { Object.new }

  before do
    # stub to prevent external calls to APIs and side effects
    # stub dependency.to_spec
    allow(dependency).to receive(:name).and_return("foo")
    allow(dependency).to receive(:description).and_return("Lorem ipsum")
    allow(dependency).to receive(:to_spec).and_return(to_spec)
    allow(to_spec).to receive(:description).and_return("description")
    allow(to_spec).to receive(:homepage).and_return("https://github.com/bar/foo")
    allow(to_spec).to receive(:version).and_return("0.4.2")
    # rubocop:disable Rspec/AnyInstance
    # stub ruby_gems
    allow_any_instance_of(GemsBond::Fetcher::RubyGems).to receive(:last_version).and_return("0.4.3")
    allow_any_instance_of(GemsBond::Fetcher::RubyGems).to receive(:downloads_count).and_return(42)
    allow_any_instance_of(GemsBond::Fetcher::RubyGems).to receive(:versions)
      .and_return([{ number: "0.4.3", created_at: "2020-1-1", prerelease: false }])
    allow_any_instance_of(GemsBond::Fetcher::RubyGems).to receive(:release_versions).and_return(["0.4.3", "0.4.2"])
    # stub github
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:login).and_return(true)
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:set_repository).and_return(true)
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:contributors_count).and_return(42)
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:stars_count).and_return(43)
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:forks_count).and_return(44)
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:last_commit_date).and_return(Date.new(2020, 1, 1))
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:open_issues_count).and_return(45)
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:lib_size).and_return(46)
    # rubocop:enable Rspec/AnyInstance
  end

  describe "#name" do
    it "returns name" do
      expect(gem.name).to eq "foo"
    end
  end

  describe "#description" do
    it "returns description" do
      expect(gem.description).to eq "Lorem ipsum"
    end
  end

  describe "#version" do
    it "returns version number" do
      expect(gem.version).to eq "0.4.2"
    end
  end

  describe "#last_version" do
    it "returns the last version" do
      expect(gem.last_version).to eq "0.4.3"
    end
  end

  describe "#downloads_count" do
    it "returns the number of downloads" do
      expect(gem.downloads_count).to eq 42
    end
  end

  describe "#versions" do
    it "returns the list of versions" do
      expect(gem.versions).to eq [{ number: "0.4.3", created_at: "2020-1-1", prerelease: false }]
    end
  end

  describe "#contributors_count" do
    it "returns the number of contributors" do
      expect(gem.contributors_count).to eq 42
    end
  end

  describe "#stars_count" do
    it "returns the number of stars" do
      expect(gem.stars_count).to eq 43
    end
  end

  describe "#forks_count" do
    it "returns the number of forks" do
      expect(gem.forks_count).to eq 44
    end
  end

  describe "#open_issues_count" do
    it "returns the number of open_issues" do
      expect(gem.open_issues_count).to eq 45
    end
  end

  describe "#last_commit_date" do
    it "returns the date of the last commit" do
      expect(gem.last_commit_date).to eq Date.new(2020, 1, 1)
    end
  end
end
