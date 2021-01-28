# frozen_string_literal: true

require "gems_bond/configuration"
require "gems_bond/railtie" if defined?(Rails)

# Gem module
module GemsBond
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
