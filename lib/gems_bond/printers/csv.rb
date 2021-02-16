# frozen_string_literal: true

require "csv"
require "gems_bond/printers/printer"

module GemsBond
  module Printers
    # Prints CSV file
    class CSV < Printer
      DATA = %w[
        name
        homepage
        source_code_uri
        version
        last_version
        last_version_date
        days_since_last_version
        last_commit_date
        days_since_last_commit
        downloads_count
        contributors_count
        stars_count
        forks_count
        open_issues_count
      ].freeze

      private

      # Prints data into a CSV file
      # @return [void]
      def print
        ::CSV.open("#{DIRECTORY_PATH}/spy.csv", "w") do |csv|
          csv << headers
          @gems.each do |gem|
            csv << row(gem)
          end
        end
      end

      # Generates CSV headers
      # @return [Array]
      def headers
        DATA
      end

      # Generates CSV row for a gem
      # @param gem [GemsBond::Gem]
      # @return [Array]
      def row(gem)
        DATA.map { |data| gem.public_send(data) }
      end
    end
  end
end
