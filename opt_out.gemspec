# -*- encoding: utf-8 -*-
require File.expand_path("../lib/opt_out/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "opt_out"
  gem.version       = OptOut::VERSION
  gem.license       = "MIT"
  gem.authors       = ["Jerry Cheung"]
  gem.email         = ["jch@whatcodecraves.com"]
  gem.description   = %q{Track newsletter unsubscriptions}
  gem.summary       = %q{Utilities for managing user unsubscribes from lists}
  gem.homepage      = "https://github.com/jch/opt_out"

  gem.files         = `git ls-files`.split $/
  gem.test_files    = gem.files.grep(%r{^test})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "redis"
end
