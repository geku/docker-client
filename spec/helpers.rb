module Helpers
  
  def create_container(name, options = {})
    VCR.use_cassette("test_setup/create_container_#{name}") do
      command = options.delete(:command) || 'env'
      container_resource.create(command, 'base', options)['Id']
    end
  end
  
  def start_container(id)
    VCR.use_cassette('test_setup/start_container') do
      container_resource.start(id)
    end
  end
  
  def delete_containers(*ids)
    VCR.use_cassette('test_setup/delete_container') do
      ids.each do |id|
        container_resource.remove(id, true) if id
      end
    end
  end
  
  def wait_on_container(id)
    VCR.use_cassette('test_setup/wait_on_container') do
      container_resource.wait(id)
    end
  end
  
  def create_and_start_container(name, options = {})
    wait = options.delete(:wait)
    
    id = create_container(name, options)
    start_container(id)
    wait_on_container(id) if wait
    
    id
  end
  
  def hello_world_command
    ['/bin/sh', '-c', 'while true; do echo hello world; sleep 1; done']
  end
  
  def container_resource
    @container ||= Docker::API.new(base_url: 'http://10.0.5.5:4243').containers
  end
  
end