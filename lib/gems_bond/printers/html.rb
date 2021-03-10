# frozen_string_literal: true

require "erb"
require "gems_bond/printers/printer"
require "gems_bond/helpers/formatting_helper"

module GemsBond
  module Printers
    # Prints HTML file
    class HTML < Printer
      include GemsBond::Helpers::FormattingHelper

      private

      # Prints data into a file
      # @return [void]
      def print
        File.open("#{DIRECTORY_PATH}/spy.html", "w") do |file|
          file.puts content
        end
      end

      # Returns the ERB template
      # @return [String]
      def template
        File.read(File.join(File.dirname(__FILE__), "../../../views/", "diagnosis.erb"))
      end

      # Returns the HTML content
      # @return [String]
      def content
        ERB.new(template).result(binding)
      end

      # Returns a color depending on the gap to last released version
      # @param gap [Integer]
      # @return [String] branding for Bootstrap use
      def version_color(gap)
        return "secondary" if gap.nil?
        return "success" if gap.zero?

        gap < 3 ? "warning" : "danger"
      end

      # Returns a color depending on the score value
      # @param score [Float] in [0, 1]
      # @return [String] branding for Bootstrap use
      def color(score)
        return "secondary" if score.nil?

        if score < 0.33
          "danger"
        elsif score < 0.66
          "warning"
        else
          "success"
        end
      end
    end
  end
end
