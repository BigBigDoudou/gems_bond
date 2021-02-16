# frozen_string_literal: true

require "fileutils"

module GemsBond
  module Printers
    # Prints HTML file
    class Printer
      DIRECTORY_PATH = "gems_bond"

      # Initializes an instance
      # @param gems [Array<GemsBond::Gem>]
      # @return [GemsBond::Printers]
      def initialize(gems)
        @gems = gems
      end

      # Manages print
      # @return [void]
      def call
        format = self.class.name.split("::").last
        puts "\nPreparing data for printing results into #{format} file..."
        create_directory
        print
        puts "Open file gems_bond/spy.#{format.downcase} to display the results."
      end

      private

      # Prints data into a file
      # @return [void]
      def print
        raise NotImplementedError, "Subclasses must implement a call method."
      end

      # Creates the "gems_bond" directory if absent
      def create_directory
        return if File.directory?(DIRECTORY_PATH)

        FileUtils.mkdir_p(DIRECTORY_PATH)
      end

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
