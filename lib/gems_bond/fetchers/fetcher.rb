# frozen_string_literal: true

require "octokit"

module GemsBond
  module Fetchers
    # Fetches data
    class Fetcher
      # Initializes an instance
      # @param param [Object] Fetcher dependent
      # @return [GemsBond::Fetchers::Fetcher]
      def initialize(param); end

      # Starts the service and returns self
      # @note rescue connection errors with nil
      def start
        raise NotImplementedError, "Subclasses must implement a start method that starts the service and returns it."
      end
    end
  end
end
