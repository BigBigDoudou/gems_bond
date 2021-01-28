# frozen_string_literal: true

require "gems_bond/examination_helper"
require_relative "../../support/gem_context"

RSpec.describe GemsBond::ExaminationHelper do
  include_context "with gem"

  let(:boundaries) { described_class::BOUNDARIES }

  describe "#examine" do
    describe "activity_score" do
      let(:activity_methods) { %w[days_since_last_version days_since_last_commit] }

      context "when data is missing" do
        before do
          activity_methods.each { |method| allow(gem).to receive(method).and_return(nil) }
        end

        it "does not set activity_score" do
          expect(gem.activity_score).to be_nil
        end
      end

      context "when the gem is very active" do
        before do
          activity_methods.each do |method|
            max = boundaries[method]["max"] || 0
            allow(gem).to receive(method).and_return(max)
          end
        end

        it "sets activity_score to a high value" do
          expect(gem.activity_score).to be > 0.9
        end
      end

      context "when the gem is not active" do
        before do
          activity_methods.each do |method|
            min = boundaries[method]["min"] || 0
            allow(gem).to receive(method).and_return(min)
          end
        end

        it "sets activity_score to a low value" do
          expect(gem.activity_score).to be < 0.1
        end
      end
    end

    describe "popularity_score" do
      let(:popularity_methods) { %w[downloads_count contributors_count forks_count stars_count open_issues_count] }

      context "when data is missing" do
        before do
          popularity_methods.each { |method| allow(gem).to receive(method).and_return(nil) }
        end

        it "does not set popularity_score" do
          expect(gem.popularity_score).to be_nil
        end
      end

      context "when the gem is very popular" do
        before do
          popularity_methods.each do |method|
            max = boundaries[method]["max"] || 0
            allow(gem).to receive(method).and_return(max)
          end
        end

        it "sets popularity_score to a high value" do
          expect(gem.popularity_score).to be > 0.9
        end
      end

      context "when the gem is not popular" do
        before do
          popularity_methods.each do |method|
            min = boundaries[method]["min"] || 0
            allow(gem).to receive(method).and_return(min)
          end
        end

        it "sets popularity_score to a low value" do
          expect(gem.popularity_score).to be < 0.1
        end
      end
    end
  end
end
