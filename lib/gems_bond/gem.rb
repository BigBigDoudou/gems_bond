# frozen_string_literal: true

require "gems_bond/fetch_helper"
require "gems_bond/examination_helper"

module GemsBond
  # Handles gem data
  class Gem
    include FetchHelper
    include ExaminationHelper

    # Initializes an instance
    # @param dependency [Bundler::Dependency]
    # @return [GemsBond::Gem]
    def initialize(dependency)
      @dependency = dependency
    end

    # Returns name
    # @return [String] (memoized)
    def name
      memoize(__method__) { @dependency.name }
    end

    # Returns description
    # @return [String] (memoized)
    def description
      memoize(__method__) { @dependency.description }
    end

    # Returns used version
    # @return [String] (memoized)
    def version
      memoize(__method__) { @dependency.to_spec.version.to_s }
    end

    # Returns homepage
    # @return [String] (memoized)
    def homepage
      memoize(__method__) { @dependency.to_spec.homepage }
    end

    # Returns url
    # @return [String]
    def url
      homepage || source_code_uri
    end

    # Returns GitHub url if exist
    # @return [String, nil]
    def github_url
      return homepage if GemsBond::Fetchers::Github.valid_url?(homepage)

      source_code_uri if GemsBond::Fetchers::Github.valid_url?(source_code_uri)
    end

    private

    # Memoizes the given key and apply the given block
    # @param key [String] the instance variable key
    # @yieldparam [Object] the value to memoize
    # @return [Object]
    def memoize(key)
      return instance_variable_get("@#{key}") if instance_variable_defined?("@#{key}")

      instance_variable_set("@#{key}", yield)
    end
  end
end
