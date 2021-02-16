# frozen_string_literal: true

require "bundler"
require "gems_bond/gem"
require "gems_bond/fetcher/ruby_gems"
require "gems_bond/fetcher/github"

RSpec.describe GemsBond::Gem do
  subject(:gem) { described_class.new(dependency) }

  let(:dependency) { Object.new }
  let(:to_spec) { Object.new }

  # stub methods to prevent API calls
  it "handles gem data", :aggregate_failures do
    # data from dependency

    allow(dependency).to receive(:name).and_return("foo")
    expect(gem.name).to eq "foo"

    allow(dependency).to receive(:description).and_return("Lorem ipsum")
    expect(gem.description).to eq "Lorem ipsum"

    allow(dependency).to receive(:to_spec).and_return(to_spec)

    allow(to_spec).to receive(:homepage).and_return("https://github.com/bar/foo")
    expect(gem.homepage).to eq "https://github.com/bar/foo"

    allow(to_spec).to receive(:version).and_return("0.4.2")
    expect(gem.version).to eq "0.4.2"

    # rubocop:disable Rspec/AnyInstance

    # data from RubyGems API

    allow_any_instance_of(GemsBond::Fetcher::RubyGems).to receive(:last_version).and_return("0.4.3")
    expect(gem.last_version).to eq "0.4.3"

    allow_any_instance_of(GemsBond::Fetcher::RubyGems).to receive(:downloads_count).and_return(42)
    expect(gem.downloads_count).to eq 42

    allow_any_instance_of(GemsBond::Fetcher::RubyGems).to receive(:versions)
      .and_return([{ number: "0.4.3", created_at: "2020-1-1", prerelease: false }])
    expect(gem.versions).to eq [{ number: "0.4.3", created_at: "2020-1-1", prerelease: false }]

    # data from GitHub API

    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:login).and_return(true)
    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:set_repository).and_return(true)

    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:contributors_count).and_return(42)
    expect(gem.contributors_count).to eq 42

    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:stars_count).and_return(43)
    expect(gem.stars_count).to eq 43

    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:forks_count).and_return(44)
    expect(gem.forks_count).to eq 44

    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:last_commit_date).and_return(Date.new(2020, 1, 1))
    expect(gem.last_commit_date).to eq Date.new(2020, 1, 1)

    allow_any_instance_of(GemsBond::Fetcher::Github).to receive(:open_issues_count).and_return(45)
    expect(gem.open_issues_count).to eq 45
    # rubocop:enable Rspec/AnyInstance
  end
end
