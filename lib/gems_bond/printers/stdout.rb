# frozen_string_literal: true

require "gems_bond/helpers/formatting_helper"

module GemsBond
  module Printers
    # Inspects gem and outputs the result
    class Stdout < SimpleDelegator
      include GemsBond::Helpers::FormattingHelper

      # Logs gem information
      # @return [void]
      def call
        line_break
        puts "--- #{name} info ---".upcase
        line_break
        puts description
        line_break
        log_url
        log_version
        log_counts
        log_activity
        line_break
        return unless unknown

        puts "Note: this gem is not listed in your current dependencies!"
        line_break
      end

      private

      # Adds a line break
      def line_break
        puts ""
      end

      # Logs url information
      def log_url
        url = source_code_uri || homepage || "?"
        puts "- url: #{url}"
      end

      # Logs version information
      def log_version
        return unless version_gap

        alert = version_gap.zero? ? "(up-to-date)" : "(#{version_gap} behind #{last_version})"
        puts "- version: #{version} #{alert}"
      end

      # Logs counts (downloads, forks, stars, contributors) information
      def log_counts
        print "- counts: "
        content = []
        add_count =
          lambda do |type|
            count = public_send("#{type}_count")
            return unless count

            content << "#{human_number(count)} #{type}"
          end

        add_count.call("downloads")
        add_count.call("forks")
        add_count.call("stars")
        add_count.call("contributors")

        puts content.empty? ? "unknown" : content.join(" | ")
      end

      # Logs activity information
      def log_activity
        print "- activity: "
        content = []
        add_days_since_last =
          lambda do |days, type|
            return if days.nil?

            unit = days.zero? || days > 1 ? "days" : "day"
            content << "#{human_number(days)} #{unit} since last #{type}"
          end

        add_days_since_last.call(days_since_last_version, "version")
        add_days_since_last.call(days_since_last_commit, "commit")

        puts content.empty? ? "unkown" : content.join(" | ")
      end
    end
  end
end
