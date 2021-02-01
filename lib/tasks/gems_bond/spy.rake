# frozen_string_literal: true

require "gems_bond/spy"

begin
  require "#{Rails.root}/config/initializers/gems_bond" if defined?(Rails)
rescue LoadError
  nil
end

namespace :gems_bond do
  desc "Investigates gems"
  task :spy do
    puts "Welcome, my name is Bond, Gems Bond."\
      " I will do some spying on your gems for you..."

    GemsBond.configure do |config|
      # set github_token from ENV if given
      config.github_token = ENV["GITHUB_TOKEN"] if ENV["GITHUB_TOKEN"]
    end

    unless GemsBond.configuration.github_token
      puts "It seems that you didn't provide any GitHub token."\
           " This is necessary to fetch more data from GitHub,"\
           " like the last commit date, the forks count, the sise of the repository..."

      puts "Please provide a GitHub token by adding it in the configuration"\
           " or passing GITHUB_TOKEN=<token> when running the task."
      exit
    end

    GemsBond::Spy.new.call
  end
end
