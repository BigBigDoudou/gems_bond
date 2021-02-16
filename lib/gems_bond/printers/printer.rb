# frozen_string_literal: true

require "erb"
require "fileutils"

module GemsBond
  module Printers
    # Prints HTML file
    class Printer
      MISSING = "-"

      # Initializes an instance
      # @param gems [Array<GemsBond::Gem>]
      # @return [GemsBond::Printers]
      def initialize(gems)
        @gems = gems
      end

      # Prints data
      # @return [void]
      def call
        raise NotImplementedError, "Subclasses must implement a call method."
      end

      private

      # Returns gems sorted by the average_score
      # @return [Array<GemsBond::Gem>]
      # @note gems with no average_score are put at the end
      def sorted_gems
        # sort with putting gems without average_score at the end
        @gems.sort do |a, b|
          if a.average_score && b.average_score
            a.average_score <=> b.average_score
          else
            a.average_score ? -1 : 1
          end
        end
      end
    end
  end
end
