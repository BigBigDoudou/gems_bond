# frozen_string_literal: true

require "gems_bond/gem"
require "gems_bond/printer"

module GemsBond
  # Inspects gems and outputs the result
  class Spy
    RETRIES = 2

    def call
      chrono do
        fetch_gems
        GemsBond::Printer.new(gems).call
      end
    end

    def gems_count
      @gems_count ||= gems.count
    end

    private

    def chrono
      start_at = Time.now
      yield
      seconds = Time.now - start_at
      time_per_gem_text = "#{(seconds / Float(gems_count)).round(2)} second(s) per gem"
      puts "\nIt took #{seconds} second(s) to spy #{gems_count} gem(s) (#{time_per_gem_text})."
    end

    def gems
      @gems ||=
        Bundler.load.current_dependencies.map do |dependency|
          GemsBond::Gem.new(dependency)
        end
    end

    def fetch_gems
      puts "Fetching data for..."
      gems.each_slice(100) do |batch|
        threads = []
        batch.each do |gem|
          threads << gem_thread(gem)
        end
        threads.each(&:join)
      end
    end

    def gem_thread(gem)
      Thread.new do
        begin
          retries ||= 0
          gem.fetch_all(verbose: true)
        # rescue SocketError, Faraday::ConnectionFailed...
        rescue StandardError
          (retries += 1) <= RETRIES ? retry : nil
        end
      end
    end
  end
end
