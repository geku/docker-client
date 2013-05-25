require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  # Documentation output
  # Disable live tests
  t.rspec_opts = "-f d -t ~live"
end

# Only run focus examples
RSpec::Core::RakeTask.new(:focus) do |t|
  t.rspec_opts = "-f d -t focus"
end

task :default => :spec
