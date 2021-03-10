# frozen_string_literal: true

module GemsBond
  # Makes Rails aware of the tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/gems_bond/spy/one.rake"
      load "tasks/gems_bond/spy/all.rake"
    end
  end
end
