# -*- mode: ruby; coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-briefcase/version'

Gem::Specification.new do |spec|
  spec.name          = "knife-briefcase"
  spec.version       = KnifeBriefcase::VERSION
  spec.authors       = ["Maciej Pasternacki"]
  spec.email         = ["maciej@pasternacki.net"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = "https://github.com/3ofcoins/knife-briefcase/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "chef"
  spec.add_dependency "gpgme"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "chef-zero"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "ridley"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "thor", "~> 0.18.1"
  spec.add_development_dependency "wrong", ">= 0.7.0"
end
