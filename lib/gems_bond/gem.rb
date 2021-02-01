# frozen_string_literal: true

require "gems_bond/fetch_helper"
require "gems_bond/examination_helper"

module GemsBond
  # Handles gem data
  class Gem
    include FetchHelper
    include ExaminationHelper

    def initialize(dependency)
      @dependency = dependency
    end

    def name
      memoize(__method__) { @dependency.name }
    end

    def description
      memoize(__method__) { @dependency.description }
    end

    def version
      memoize(__method__) { @dependency.to_spec.version.to_s }
    end

    def homepage
      memoize(__method__) { @dependency.to_spec.homepage }
    end

    def url
      homepage || source_code_uri
    end

    def github_url
      return homepage if GemsBond::Fetcher::Github.valid_url?(homepage)

      source_code_uri if GemsBond::Fetcher::Github.valid_url?(source_code_uri)
    end

    private

    def memoize(key)
      return instance_variable_get("@#{key}") if instance_variable_defined?("@#{key}")

      instance_variable_set("@#{key}", yield)
    end
  end
end
