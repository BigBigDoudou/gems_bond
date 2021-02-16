# frozen_string_literal: true

require "erb"
require "fileutils"

module GemsBond
  # Prints gems table
  class Printer
    MISSING = "-"

    # Initializes an instance
    # @param gems [Array<GemsBond::Gem>]
    # @return [GemsBond::Printer]
    def initialize(gems)
      @gems = gems
    end

    # Prints data into an HTML file
    # @return [void]
    def call
      puts "\nPreparing data for printing results..."
      create_directory
      File.open("gems_bond/spy.html", "w") do |file|
        file.puts content
      end
      puts "Open file gems_bond/spy.html to display the results."
    end

    private

    # Creates the "gems_bond" directory if absent
    def create_directory
      return if File.directory?("gems_bond")

      FileUtils.mkdir_p("gems_bond")
    end

    # Returns the ERB template
    # @return [String]
    def template
      File.read(File.join(File.dirname(__FILE__), "../../views/", "diagnosis.erb"))
    end

    # Returns the HTML content
    # @return [String]
    def content
      ERB.new(template).result(binding)
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
