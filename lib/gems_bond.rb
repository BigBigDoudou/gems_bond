# frozen_string_literal: true

require "gems_bond/configuration"
require "gems_bond/railtie" if defined?(Rails)

# Gem module
module GemsBond
  class << self
    attr_accessor :configuration

    # Configures Gems Bond
    # @return GemsBond::Configuration
    # @yieldparam [Proc] configuration to apply
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
