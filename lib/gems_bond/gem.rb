# frozen_string_literal: true

require "gems_bond/helpers/concurrency_helper"
require "gems_bond/fetchers/ruby_gems"
require "gems_bond/fetchers/github"
require "gems_bond/examination"

module GemsBond
  # Handles gem data
  class Gem
    include GemsBond::Helpers::ConcurrencyHelper
    include GemsBond::Examination

    attr_reader :unknown

    RUBY_GEM_KEYS = %i[
      days_since_last_version downloads_count info last_version last_version_date source_code_uri versions
    ].freeze

    GITHUB_KEYS = %i[
      contributors_count days_since_last_commit forks_count last_commit_date open_issues_count stars_count
    ].freeze

    # Initializes an instance
    # @param dependency [Bundler::Dependency]
    # @param unknown [Boolean] is it a current dependency?
    # @return [GemsBond::Gem]
    def initialize(dependency, unknown: false)
      @dependency = dependency
      @unknown = unknown
    end

    # Is the gem hosted on RubyGems?
    # @retun [Boolean]
    def exist?
      ruby_gems_fetcher.started?
    end

    # Returns name
    # @return [String] (memoized)
    def name
      memoize(__method__) { @dependency.name }
    end

    # Returns description
    # @return [String] (memoized)
    def description
      memoize(__method__) do
        unknown ? info : @dependency.to_spec.description
      end
    end

    # Returns used version
    # @return [String] (memoized)
    def version
      memoize(__method__) do
        @dependency.to_spec.version.to_s unless unknown
      end
    end

    # Returns homepage
    # @return [String] (memoized)
    def homepage
      memoize(__method__) do
        @dependency.to_spec.homepage unless unknown
      end
    end

    # Returns url
    # @return [String]
    def url
      homepage || source_code_uri
    end

    # Returns GitHub url if exist
    # @return [String, nil]
    def github_url
      [homepage, source_code_uri].find do |url|
        GemsBond::Fetchers::Github.valid_url?(url)
      end
    end

    RUBY_GEM_KEYS.each do |key|
      define_method(key) do
        memoize(key) do
          fetch(ruby_gems_fetcher, key)
        end
      end
    end

    GITHUB_KEYS.each do |key|
      define_method(key) do
        memoize(key) do
          fetch(github_fetcher, key)
        end
      end
    end

    # Returns gap between installed and last released version, in days
    # @return [Integer, nil] (memoized)
    def version_gap
      memoize(:version_gap) do
        return unless version && versions

        index = versions.index { |v| v[:number] == version }
        return unless index

        gap = versions[0..index].count { |v| !v[:prerelease] } - 1
        gap.positive? ? gap : 0
      end
    end

    # Fetches data from APIs
    # @param concurrency [Boolean] should it be run concurrently?
    # @param verbose [Boolean] should gem's name be stdout?
    # @return [void]
    def prepare_data(keys: nil, concurrency: false, verbose: false)
      fetch_key = ->(key) { (keys.nil? || key.in?(keys)) && __send__(key) }
      if concurrency
        each_concurrently(RUBY_GEM_KEYS + GITHUB_KEYS, &fetch_key)
      else
        (RUBY_GEM_KEYS + GITHUB_KEYS).each(&fetch_key)
      end
      puts(name) if verbose
    end

    private

    # Fetches the given data with the given fetcher
    # @param fetcher [GemsBond::Fetchers]
    # @param key [String]
    # @return [Object, nil]
    def fetch(fetcher, key)
      return if fetcher.nil?
      raise GemsBond::Fetchers::NotStartedError unless fetcher.started?

      fetcher.public_send(key)
    end

    # Returns a started RubyGems fetcher
    # @return [GemsBond::Fetchers::RubyGems, nil]
    # @note #start is needed to ensure the fetcher works
    def ruby_gems_fetcher
      return @ruby_gems_fetcher if defined?(@ruby_gems_fetcher)

      @ruby_gems_fetcher = GemsBond::Fetchers::RubyGems.new(name).tap(&:start)
    end

    # Returns a started GitHub fetcher
    # @return [GemsBond::Fetchers::Github, nil]
    # @note #start is needed to ensure the fetcher works (especially the token)
    def github_fetcher
      return @github_fetcher if defined?(@github_fetcher)

      @github_fetcher = github_url && GemsBond::Fetchers::Github.new(github_url).tap(&:start)
    end

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
