# frozen_string_literal: true

require "erb"
require "gems_bond/printers/printer"

module GemsBond
  module Printers
    # Prints HTML file
    class HTML < Printer
      MISSING = "-"

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

      # Returns a date with a readable format
      # @param date [Date]
      # @return [String]
      # @example
      #   human_date(Date.new(2017, 11, 19)) #=> "2007-11-19"
      #   human_date(nil) #=> "-"
      def human_date(date)
        return MISSING if date.nil?

        date.strftime("%F")
      end

      # Returns a number with a readable format
      # @param date [Integer]
      # @return [String]
      # @example
      #   human_number(1_000_000) #=> "1 000 000"
      #   human_number(nil) #=> "-"
      def human_number(number)
        return MISSING if number.nil?

        number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1 ")
      end

      # Returns score out of 100
      # @param date [Float]
      # @return [String]
      # @example
      #   human_score(0.5) #=> "50"
      #   human_score(nil) #=> "-"
      def human_score(score)
        return MISSING if score.nil?

        (score * 100).round
      end
    end
  end
end
