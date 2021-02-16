# frozen_string_literal: true

require "gems_bond/printers/csv"

RSpec.describe GemsBond::Printers::CSV do
  let(:gems) do
    Array.new(2) do |i|
      instance_double(
        "gem",
        name: "gem#{i}",
        homepage: "https://homepage#{i}.com",
        source_code_uri: "https://source_code#{i}.com",
        version: "#{i}.0.0",
        last_version: "#{i}.0.1",
        last_version_date: Date.new(2020, 3, i + 1),
        days_since_last_version: 100 * i,
        last_commit_date: Date.new(2020, 6, i + 1),
        days_since_last_commit: 200 * i,
        downloads_count: 42 * i,
        contributors_count: 43 * i,
        stars_count: 44 * i,
        forks_count: 45 * i,
        open_issues_count: 46 * i
      )
    end
  end

  let(:expectation) do
    expected_headers = [described_class::DATA]
    expected_rows =
      Array.new(2) do |i|
        [
          "gem#{i}",
          "https://homepage#{i}.com",
          "https://source_code#{i}.com",
          "#{i}.0.0",
          "#{i}.0.1",
          "2020-03-0#{i + 1}",
          (100 * i).to_s,
          "2020-06-0#{i + 1}",
          (200 * i).to_s,
          (42 * i).to_s,
          (43 * i).to_s,
          (44 * i).to_s,
          (45 * i).to_s,
          (46 * i).to_s
        ]
      end
    expected_headers + expected_rows
  end

  it "prints CSV" do
    stub_const("#{described_class.name}::DIRECTORY_PATH", "spec/tmp")
    described_class.new(gems).call
    output = CSV.read("spec/tmp/spy.csv")
    expect(output).to eq expectation
  end
end
