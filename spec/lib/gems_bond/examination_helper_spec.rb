# frozen_string_literal: true

require "gems_bond/examination_helper"

RSpec.describe GemsBond::ExaminationHelper do
  let(:gem) { GemsBond::Gem.new(nil) }

  before do
    allow(gem).to receive(:name)
    allow(gem).to receive(:homepage)
  end

  describe "activity_score" do
    # methods used to calculate score
    let(:methods) { %w[contributors_count days_since_last_version days_since_last_commit open_issues_count] }

    context "when data is missing" do
      it "returns nil" do
        methods.each { |method| allow(gem).to receive(method).and_return(nil) }
        expect(gem.activity_score).to be_nil
      end
    end

    context "when the gem is not active" do
      it "returns a value close to 0 (low)" do
        methods.each do |method|
          allow(gem).to receive(method).and_return(described_class::BOUNDARIES[method]["min"] || 0)
        end
        expect(gem.activity_score).to be < 0.1
      end
    end

    context "when the gem is very active" do
      it "returns a value close to 1 (high)" do
        methods.each do |method|
          allow(gem).to receive(method).and_return(described_class::BOUNDARIES[method]["max"] || 0)
        end
        expect(gem.activity_score).to be > 0.9
      end
    end
  end

  describe "popularity_score" do
    # methods used to calculate score
    let(:methods) { %w[downloads_count contributors_count forks_count stars_count] }

    context "when data is missing" do
      it "returns nil" do
        methods.each { |method| allow(gem).to receive(method).and_return(nil) }
        expect(gem.popularity_score).to be_nil
      end
    end

    context "when the gem is not popular" do
      it "returns a value close to 0 (low)" do
        methods.each do |method|
          allow(gem).to receive(method).and_return(described_class::BOUNDARIES[method]["min"] || 0)
        end
        expect(gem.popularity_score).to be < 0.1
      end
    end

    context "when the gem is very popular" do
      it "returns a value close to 1 (high)" do
        methods.each do |method|
          allow(gem).to receive(method).and_return(described_class::BOUNDARIES[method]["max"] || 0)
        end
        expect(gem.popularity_score).to be > 0.9
      end
    end
  end
end
