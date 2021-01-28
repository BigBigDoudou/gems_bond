# frozen_string_literal: true

require "erb"
require "fileutils"

module GemsBond
  # Prints gems table
  class Printer
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
      @gems.sort_by(&:average_score)
    end

    def version_color(gap)
      return "success" if gap.zero?

      gap < 3 ? "warning" : "danger"
    end

    def color(score)
      if score < 0.33
        "danger"
      elsif score < 0.66
        "warning"
      else
        "success"
      end
    end

    def human_date(date)
      date&.strftime("%F") || "-"
    end

    def human_number(number)
      number&.to_s&.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1 ") || "-"
    end

    def human_score(score)
      (score * 100).round || "-"
    end
  end
end
