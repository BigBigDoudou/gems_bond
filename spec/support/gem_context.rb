# frozen_string_literal: true

require "gems_bond/gem"

RSpec.shared_context "with gem" do
  let(:gem) { GemsBond::Gem.new(dependency) }
  let(:dependency) { Object.new }

  let(:methods) do
    %i[
      name
      description
      homepage
      version
      versions
      last_commit_date
      open_issues_count
      downloads_count
      contributors_count
      stars_count
      forks_count
    ]
  end

  before do
    methods.each do |method_name|
      allow(gem).to receive(method_name).and_return(nil)
      allow(gem).to receive(:log_diagnosis) # prevent stdout
    end
  end
end
