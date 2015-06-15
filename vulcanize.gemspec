# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vulcanize/version'

Gem::Specification.new do |spec|
  spec.name          = "vulcanize"
  spec.version       = Vulcanize::VERSION
  spec.authors       = ["Peter Saxton"]
  spec.email         = ["vulcanize@workshop14.io"]
  spec.summary       = %q{Form objects for coercing user input to domain specific objects}
  spec.description   = %q{Forms consist of one or more attributes that are defined with a name, type and optional parameters. Plain ruby classes are used to represent attribute type and should be responsible for coercing the raw input and deciding an inputs validity.}
  spec.homepage      = "https://github.com/CrowdHailer/vulcanize"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.4"
  spec.add_development_dependency "minitest-reporters", "~> 1.0"
end
