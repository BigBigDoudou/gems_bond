# frozen_string_literal: true

module GemsBond
  module Helpers
    # Formatting helper
    module FormattingHelper
      MISSING = "-"

      module_function

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
