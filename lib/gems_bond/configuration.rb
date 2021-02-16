# frozen_string_literal: true

module GemsBond
  # Manages gem configuration
  class Configuration
    attr_accessor :github_token

    # Initializes the configuration
    # @return [GemsBond::Configuration]
    def initialize
      @github_token = nil
    end
  end
end
