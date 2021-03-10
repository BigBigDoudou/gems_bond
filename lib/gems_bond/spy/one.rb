# frozen_string_literal: true

require "gems_bond/gem"
require "gems_bond/printers/stdout"

module GemsBond
  module Spy
    # Inspects gem and outputs the result in terminal
    class One
      PRELOAD_KEYS = %i[
        contributors_count
        days_since_last_commit
        days_since_last_version
        downloads_count
        forks_count
        source_code_uri
        stars_count
        versions
      ].freeze

      # Initializes an instance
      # @param name [String]
      # @return [GemsBond::Spy::One]
      def initialize(name)
        @name = name
      end

      # Fetches gem then prints information
      # @return [void]
      def call
        if gem.exist?
          gem.prepare_data(keys: PRELOAD_KEYS, concurrency: false)
          GemsBond::Printers::Stdout.new(gem).call
        else
          puts "Sorry, this gem could not be found!"
        end
      end

      private

      # Finds dependency corresponding to the name
      # @return [Bundler::Dependency, nil]
      def dependency
        @dependency ||= Bundler.load.gems.find { |dep| dep.name == @name }
      end

      # Generates a gem instance
      # @return [GemsBond::Gem]
      def gem
        if dependency
          GemsBond::Gem.new(dependency)
        else
          unknown_dependency = Bundler::Dependency.new(@name, nil)
          GemsBond::Gem.new(unknown_dependency, unknown: true)
        end
      end
    end
  end
end
