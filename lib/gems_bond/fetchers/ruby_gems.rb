# frozen_string_literal: true

require "gems"
require "rubygems"
require "gems_bond/fetchers/fetcher"

module GemsBond
  module Fetchers
    # Fetches data from RubyGems
    class RubyGems < Fetcher
      # Initializes an instance
      # @param name [String] name of the gem
      # @return [GemsBond::Fetchers::RubyGems]
      def initialize(name)
        super(name)
        @name = name
      end

      # Starts the service and returns self
      # @return [GemsBond::Fetchers::RubyGems, nil]
      # @note rescue connection errors with nil
      def start
        # ensure gem exists (otherwise it raises Gems error)
        @info = Gems.info(@name)
        self
      rescue Gems::NotFound
        nil
      end

      # Returns number of downloads
      # @return [Integer]
      def downloads_count
        Gems.total_downloads(@name)[:total_downloads]
      end

      # Returns source code URI
      # @return [String]
      def source_code_uri
        @info["metadata"]["source_code_uri"]
      end

      # Returns versions data (number, date and if it is a prerelease)
      # @return [Array<Hash>]
      # @note each hash structure: { number: String, created_at: Date, prerelease: Boolean }
      def versions
        Gems.versions(@name).map do |version|
          {
            number: version["number"],
            created_at: Date.parse(version["created_at"]),
            prerelease: version["prerelease"]
          }
        end
      end

      # Returns last version number
      # @return [String]
      def last_version
        versions&.first&.dig(:number)
      end

      # Returns last version date
      # @return [Date]
      def last_version_date
        versions&.first&.dig(:created_at)
      end

      # Returns number of days since last version
      # @return [Integer]
      def days_since_last_version
        return unless last_version_date

        Date.today - last_version_date
      end
    end
  end
end
