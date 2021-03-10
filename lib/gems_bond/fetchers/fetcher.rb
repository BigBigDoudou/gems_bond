# frozen_string_literal: true

require "octokit"

module GemsBond
  module Fetchers
    class NotStartedError < StandardError; end

    # Fetches data
    class Fetcher
      # Initializes an instance
      # @param param [Object] Fetcher dependent
      # @return [GemsBond::Fetchers::Fetcher]
      def initialize(param); end

      # Starts the service and returns self
      # @note rescue connection errors with nil
      def start
        @started = true
      end

      # Starts the service and returns self
      # @note rescue connection errors with nil
      def stop
        @started = false
      end

      # Is the service started?
      def started?
        @started
      end
    end
  end
end
