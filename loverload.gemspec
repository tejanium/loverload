# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loverload/version'

Gem::Specification.new do |spec|
  spec.name          = "loverload"
  spec.version       = Loverload::VERSION
  spec.authors       = ["Teja Sophista V.R."]
  spec.email         = ["tejanium@yahoo.com"]
  spec.description   = %q{DSL for building method overloading in Ruby more magical}
  spec.summary       = %q{DSL for building method overloading in Ruby}
  spec.homepage      = "http://github.com/tejanium/loverload"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"
end
