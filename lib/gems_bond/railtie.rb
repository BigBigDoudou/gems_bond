# frozen_string_literal: true

module GemsBond
  # Makes Rails aware of the tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/gems_bond/spy.rake"
    end
  end
end
