# frozen_string_literal: true

require "gems_bond/spy/one"

begin
  require "#{Rails.root}/config/initializers/gems_bond" if defined?(Rails)
rescue LoadError
  nil
end

namespace :gems_bond do
  namespace :spy do
    desc "Display information for the given gem"
    task :one do
      GemsBond.configure do |config|
        # set github_token from ENV if given
        config.github_token = ENV["GITHUB_TOKEN"] if ENV["GITHUB_TOKEN"]
      end

      ARGV.each { |a| task(a) }
      name = ARGV[1]
      if name
        GemsBond::Spy::One.new(name).call
      else
        puts "Please provide the gem name, for example: `rake gems_bond:spy:one devise`"
      end
    end
  end
end
