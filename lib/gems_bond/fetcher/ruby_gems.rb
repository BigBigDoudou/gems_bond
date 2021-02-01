# frozen_string_literal: true

require "gems"
require "rubygems"

module GemsBond
  module Fetcher
    # Fetches data from RubyGems
    class RubyGems
      def initialize(name)
        @name = name
      end

      def source
        "ruby gems"
      end

      def start
        @info = Gems.info(@name)
        self
      rescue Gems::NotFound
        nil
      end

      def downloads_count
        Gems.total_downloads(@name)[:total_downloads]
      end

      def source_code_uri
        @info["metadata"]["source_code_uri"]
      end

      def versions
        Gems.versions(@name).map do |version|
          {
            number: version["number"],
            created_at: Date.parse(version["created_at"]),
            prerelease: version["prerelease"]
          }
        end
      end

      def last_version
        versions&.first&.dig(:number)
      end

      def last_version_date
        versions&.first&.dig(:created_at)
      end

      def days_since_last_version
        return unless last_version_date

        Date.today - last_version_date
      end
    end
  end
end
