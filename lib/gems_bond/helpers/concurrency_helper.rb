# frozen_string_literal: true

module GemsBond
  module Helpers
    # Concurrency helper
    module ConcurrencyHelper
      # Run each item concurrently
      # @param items [Boolean] items to process
      # @yield [item] apply to each item
      # @return [void]
      # @example
      #   each_concurrently(words) do |word|
      #     dictionnary_api.fetch(word)
      #   end
      def each_concurrently(items)
        threads = []
        items.each do |item|
          threads << Thread.new { block_given? ? yield(item) : item }
        end
        threads.each(&:join)
      end
    end
  end
end
