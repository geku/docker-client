# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docker/version'

Gem::Specification.new do |spec|
  spec.name          = 'docker-client'
  spec.version       = Docker::VERSION
  spec.authors       = ['Georg Kunz']
  spec.email         = ['kwd@gmx.ch']
  spec.description   = %q{Docker client}
  spec.summary       = %q{Docker client library to access the Docker remote API.}
  spec.homepage      = 'https://github.com/geku/docker-client'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 1.9'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.13'
  spec.add_development_dependency 'vcr', '~> 2.5'
  spec.add_development_dependency 'webmock', '~> 1.11'
  spec.add_development_dependency 'activesupport', '~> 3.2.13'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'awesome_print'
  
  spec.add_runtime_dependency 'multi_json', '~> 1.7'
  spec.add_runtime_dependency 'json', '~> 1.8'
  spec.add_runtime_dependency 'curb', '~> 0.8.4'
  
end
