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
  
  def commit_container(id, repo)
    VCR.use_cassette('test_setup/commit_container') do
      container_resource.commit(id, repo)['Id']
    end
  end
  
  def create_and_start_container(name, options = {})
    wait   = options.delete(:wait)
    
    id = create_container(name, options)
    start_container(id)
    wait_on_container(id) if wait
    
    id
  end
  
  def hello_world_command
    ['/bin/sh', '-c', 'while true; do echo hello world; sleep 1; done']
  end
  
  def create_image(name)
    container_id = create_and_start_container(name, command: ['touch', '/tmp/changes'], wait: true, commit: true)
    image_id = commit_container(container_id, name)
    delete_containers(container_id)
    image_id
  end
  
  def delete_images(*ids)
    VCR.use_cassette('test_setup/delete_image') do
      ids.each do |id|
        image_resource.remove(id) if id
      end
    end
  end
  
  def auth
    VCR.use_cassette('test_setup/auth') do
      system_ressource.auth(ENV['DOCKER_USERNAME'], ENV['DOCKER_EMAIL'], ENV['DOCKER_PASSWORD'])
    end
  end
  
  def uri_for(path)
    "#{ENV['DOCKER_BASE_URL']}/#{path}"
  end
  
  def image_resource
    @_image ||= docker_resource.images
  end
  
  def container_resource
    @_container ||= docker_resource.containers
  end
  
  def system_ressource
    @_system ||= docker_resource.system
  end
  
  def docker_resource
    @_docker ||= Docker::API.new(base_url: ENV['DOCKER_BASE_URL'])
  end
  
end