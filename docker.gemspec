# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docker/version'

Gem::Specification.new do |spec|
  spec.name          = "docker"
  spec.version       = Docker::VERSION
  spec.authors       = ["Georg Kunz"]
  spec.email         = ["kwd@gmx.ch"]
  spec.description   = %q{Docker client}
  spec.summary       = %q{Docker client library accessing the Docker remote API.}
  spec.homepage      = "http://georgkunz.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 1.9"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  
  spec.add_runtime_dependency "multi_json"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "curb"
end
