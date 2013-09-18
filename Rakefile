require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'docker'

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

namespace :docker do
  desc "Stop and delete all Docker containers" 
  task :cleanup do
    container = Docker::API.new(base_url: ENV['DOCKER_BASE_URL']).containers
    counter = 0
    container.list(all: true).each do |c|
      puts "Delete container #{c['Id']}"
      container.remove(c['Id'])
      counter += 1
    end
    
    puts "Total of #{counter} containers deleted"
    
  end
end

