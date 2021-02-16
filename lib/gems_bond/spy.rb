# frozen_string_literal: true

require "gems_bond/gem"
require "gems_bond/printer"

module GemsBond
  # Inspects gems and outputs the result
  class Spy
    # Number of fetch retries before skipping gem
    RETRIES = 2

    # Fetches and scores gems then prints result
    # @return [void]
    def call
      timer do
        fetch_gems_data
        GemsBond::Printer.new(gems).call
      end
    end

    private

    # Returns number of gems
    # @return [Integer]
    def gems_count
      @gems_count ||= gems.count
    end

    # Starts a timer and executes given block
    # @yieldparam [Proc] code to execute and time
    # @return [void] (stdout)
    def timer
      start_at = Time.now
      yield
      seconds = Time.now - start_at
      time_per_gem_text = "#{(seconds / Float(gems_count)).round(2)} second(s) per gem"
      puts "\nIt took #{seconds} second(s) to spy #{gems_count} gem(s) (#{time_per_gem_text})."
    end

    # Returns list of gems to spy
    # @return [Array<GemsBond::Gem>]
    def gems
      @gems ||=
        Bundler.load.current_dependencies.map do |dependency|
          GemsBond::Gem.new(dependency)
        end
    end

    # Fetches data for each gem
    # @return [void] (mutate gems)
    # @note use concurrency to fetch quickly fetch data from APIs
    def fetch_gems_data
      puts "Fetching data for..."
      # slice 100 to avoid too many requests on RubyGems and GitHub APIs
      gems.each_slice(100) do |batch|
        threads = []
        batch.each do |gem|
          threads << gem_thread(gem)
        end
        threads.each(&:join)
      end
    end

    # Starts a thread to process the given gem
    # @param gem [GemsBond::Gem] gem to process
    # @note if there is a connection/API error
    #   retry or rescue if too many retries
    def gem_thread(gem)
      Thread.new do
        begin
          retries ||= 0
          # set verbose to true to stdout the gem name
          gem.fetch_all(verbose: true)
        # rescue SocketError, Faraday::ConnectionFailed...
        rescue StandardError
          (retries += 1) <= RETRIES ? retry : nil
        end
      end
    end
  end
end
