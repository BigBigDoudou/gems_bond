# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "gems_bond/version"

Gem::Specification.new do |spec|
  spec.name          = "gems_bond"
  spec.version       = GemsBond::VERSION
  spec.authors       = ["Edouard Piron"]
  spec.email         = ["edouard.piron@gmail.com"]

  spec.summary       = "Inspect gems"
  spec.description   = "Inspect gems"
  spec.homepage      = "https://github.com/BigBigDoudou/gems_bond"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4")

  spec.files = Dir["lib/**/*.rb"] + Dir["lib/**/*.yml"] + Dir["lib/tasks/**/*.rake"] + Dir["views/**/*.erb"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.add_dependency "gems"
  spec.add_dependency "octokit", "~> 4.0"
end
