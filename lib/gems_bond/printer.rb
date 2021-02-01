# frozen_string_literal: true

require "erb"
require "fileutils"

module GemsBond
  # Prints gems table
  class Printer
    MISSING = "-"

    def initialize(gems)
      @gems = gems
    end

    def call
      puts "\nPreparing data for printing results..."
      create_directory
      File.open("gems_bond/spy.html", "w") do |file|
        file.puts content
      end
      puts "Open file gems_bond/spy.html to display the results."
    end

    private

    def create_directory
      return if File.directory?("gems_bond")

      FileUtils.mkdir_p("gems_bond")
    end

    def template
      File.read(File.join(File.dirname(__FILE__), "../../views/", "diagnosis.erb"))
    end

    def content
      ERB.new(template).result(binding)
    end

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

    def version_color(gap)
      return "secondary" if gap.nil?
      return "success" if gap.zero?

      gap < 3 ? "warning" : "danger"
    end

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

    def human_date(date)
      return MISSING if date.nil?

      date.strftime("%F")
    end

    def human_number(number)
      return MISSING if number.nil?

      number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1 ")
    end

    def human_score(score)
      return MISSING if score.nil?

      (score * 100).round
    end
  end
end
